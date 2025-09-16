require "httparty"

# Configurable vars
LIMIT = ENV.fetch("SEED_LIMIT", 50).to_i
PAGES = ENV.fetch("SEED_PAGES", 2).to_i
PAUSE = ENV.fetch("SEED_PAUSE", 0.2).to_f

# Helper to fetch with retries + User-Agent
def fetch_with_retry(url, retries: ENV.fetch("SEED_RETRIES", 5).to_i, timeout: ENV.fetch("SEED_TIMEOUT", 8).to_i)
  tries = 0
  begin
    HTTParty.get(url, headers: { "User-Agent" => "IntroRailsSeeder/1.0 (contact: kareemrussell04@gmail.com)" }, timeout: timeout)
  rescue => e
    tries += 1
    if tries <= retries
      puts "⚠️ Retry #{tries}/#{retries} for #{url} (#{e.message})"
      sleep 0.5
      retry
    else
      puts "❌ Giving up on #{url}"
      nil
    end
  end
end

subjects = ["horror", "fantasy", "romance", "poetry", "thriller"]

subjects.each do |subject|
  puts "📚 Seeding subject: #{subject}"

  PAGES.times do |page|
    encoded_term = URI.encode_www_form_component(subject)
    url = "https://openlibrary.org/subjects/#{encoded_term}.json?limit=#{LIMIT}&offset=#{page * LIMIT}"
    response = fetch_with_retry(url)
    next unless response&.success?

    data = JSON.parse(response.body)

    Array(data["works"]).each do |work|
      title            = work["title"] || "Unknown Title"
      first_publish    = work["first_publish_year"]
      edition_count    = work["edition_count"] || 0
      cover_identifier = work["cover_id"]
      work_key         = work["key"]

      # Work details
      description = "Book description not found"
      begin
        work_url      = "https://openlibrary.org#{work_key}.json"
        work_response = fetch_with_retry(work_url)
        if work_response&.success?
          work_data = JSON.parse(work_response.body)
          if work_data["description"].present?
            description =
              work_data["description"].is_a?(Hash) ? work_data["description"]["value"] : work_data["description"]
          end
        end
      rescue => e
        puts "⚠️ Failed to fetch work #{work_key}: #{e.message}"
      end

      book = Book.find_or_create_by(work_key: work_key) do |b|
        b.title              = title
        b.description        = description
        b.subject            = subject
        b.first_publish_year = first_publish
        b.edition_count      = edition_count
        b.cover_identifier   = cover_identifier
      end

      # Authors
      authors = Array(work["authors"])
      if authors.size == 1
        author_ref = authors.first
        author_key = author_ref["key"]
        author_url = "https://openlibrary.org#{author_key}.json"
        author_resp = fetch_with_retry(author_url)

        if author_resp&.success?
          author_data = JSON.parse(author_resp.body)
          author_name = author_data["name"]
          biography   =
            if author_data["bio"].present?
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

      elsif authors.size > 1
        names = authors.map { |a| a["name"] }
        if names.uniq.size == 1
          author_ref = authors.first
          author_key = author_ref["key"]
          author_url = "https://openlibrary.org#{author_key}.json"
          author_resp = fetch_with_retry(author_url)

          if author_resp&.success?
            author_data = JSON.parse(author_resp.body)
            author_name = author_data["name"]
            biography   =
              if author_data["bio"].present?
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
        else
          authors.each do |author_ref|
            author_key = author_ref["key"]
            author_url = "https://openlibrary.org#{author_key}.json"
            author_resp = fetch_with_retry(author_url)

            if author_resp&.success?
              author_data = JSON.parse(author_resp.body)
              author_name = author_data["name"]
              biography   =
                if author_data["bio"].present?
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
        end
      end
    end

    sleep(PAUSE)
  end
end