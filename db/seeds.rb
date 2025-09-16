# db/seeds.rb
require "httparty"
require "uri"
require "json"

SUBJECTS = %w[horror fantasy romance poetry thriller].freeze
LIMIT    = Integer(ENV.fetch("SEED_LIMIT", 100))     # works per page
PAGES    = Integer(ENV.fetch("SEED_PAGES", 3))       # how many pages (0..PAGES-1)
PAUSE    = Float(ENV.fetch("SEED_PAUSE", 0.08))      # seconds between requests
TIMEOUT  = Integer(ENV.fetch("SEED_TIMEOUT", 5))     # seconds per request
RETRIES  = Integer(ENV.fetch("SEED_RETRIES", 3))     # retries for 503s etc.

def fetch_json(url, retries: RETRIES, timeout: TIMEOUT, pause: PAUSE)
  tries = 0
  begin
    resp = HTTParty.get(url, timeout: timeout)
    return nil unless resp.success?
    JSON.parse(resp.body)
  rescue StandardError
    tries += 1
    if tries < retries
      sleep(pause * tries)
      retry
    end
    nil
  ensure
    sleep(pause)
  end
end

SUBJECTS.each do |subject|
  puts "📚 Seeding subject: #{subject}"

  PAGES.times do |i|
    offset = i * LIMIT
    encoded = URI.encode_www_form_component(subject)
    url = "https://openlibrary.org/subjects/#{encoded}.json?limit=#{LIMIT}&offset=#{offset}"

    data = fetch_json(url)
    break unless data && data["works"].is_a?(Array) && data["works"].any?

    data["works"].each do |work|
      title            = work["title"] || "Unknown Title"
      first_publish    = work["first_publish_year"]
      edition_count    = work["edition_count"] || 0
      cover_identifier = work["cover_id"]
      work_key         = work["key"]

      # Work details (fail-soft)
      description = "Book description not found"
      if work_key
        work_url  = "https://openlibrary.org#{work_key}.json"
        work_data = fetch_json(work_url)
        if work_data && work_data["description"].present?
          description = work_data["description"].is_a?(Hash) ? work_data["description"]["value"] : work_data["description"]
        end
      end

      book = Book.find_or_create_by(work_key: work_key) do |b|
        b.title              = title
        b.description        = description
        b.subject            = subject
        b.first_publish_year = first_publish
        b.edition_count      = edition_count
        b.cover_identifier   = cover_identifier
      end

      authors = Array(work["authors"])

      if authors.size == 1
        # Single author
        author_key = authors.first["key"]
        if author_key
          author_data = fetch_json("https://openlibrary.org#{author_key}.json")
          if author_data
            author_name = author_data["name"]
            biography = if author_data["bio"].present?
                          author_data["bio"].is_a?(Hash) ? author_data["bio"]["value"] : author_data["bio"]
                        else
                          "Author biography not found"
                        end
            author = Author.find_or_create_by(author_key: author_key) do |a|
              a.author_name = author_name
              a.biography   = biography
            end
            book.authors << author unless book.authors.include?(author)
          end
        end

      elsif authors.size > 1
        # Multiple authors — your original de-dupe quirk
        names = authors.map { |a| a["name"] }.compact
        if names.uniq.size == 1
          # All names identical -> just pick the first key
          author_key = authors.first["key"]
          if author_key
            author_data = fetch_json("https://openlibrary.org#{author_key}.json")
            if author_data
              author_name = author_data["name"]
              biography = if author_data["bio"].present?
                            author_data["bio"].is_a?(Hash) ? author_data["bio"]["value"] : author_data["bio"]
                          else
                            "Author biography not found"
                          end
              author = Author.find_or_create_by(author_key: author_key) do |a|
                a.author_name = author_name
                a.biography   = biography
              end
              book.authors << author unless book.authors.include?(author)
            end
          end
        else
          # Different authors -> attach each, fail-soft per author
          authors.each do |a_ref|
            a_key = a_ref["key"]
            next unless a_key
            a_data = fetch_json("https://openlibrary.org#{a_key}.json")
            next unless a_data

            a_name = a_data["name"]
            bio = if a_data["bio"].present?
                    a_data["bio"].is_a?(Hash) ? a_data["bio"]["value"] : a_data["bio"]
                  else
                    "Author biography not found"
                  end
            author = Author.find_or_create_by(author_key: a_key) do |a|
              a.author_name = a_name
              a.biography   = bio
            end
            book.authors << author unless book.authors.include?(author)
          end
        end
      end
    end
  end
end

puts "✅ Seeding complete"
