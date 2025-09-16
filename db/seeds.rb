require "httparty"

subjects = ["horror", "fantasy", "romance", "poetry", "thriller"]

subjects.each do |subject|
  puts "📚 Seeding subject: #{subject}"
  encoded_term = URI.encode_www_form_component(subject)
  url = "https://openlibrary.org/subjects/#{encoded_term}.json?limit=50"

  begin
    response = HTTParty.get(url)
    next unless response.success?

    data = JSON.parse(response.body)
  rescue => e
    puts "⚠️ Failed to fetch subject #{subject}: #{e.message}"
    next
  end

  Array(data["works"]).each do |work|
    title            = work["title"] || "Unknown Title"
    first_publish    = work["first_publish_year"]
    edition_count    = work["edition_count"] || 0
    cover_identifier = work["cover_id"]
    work_key         = work["key"]

    # Fetch work details
    description = "Book description not found"
    begin
      work_url      = "https://openlibrary.org#{work_key}.json"
      work_response = HTTParty.get(work_url)
      if work_response.success?
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

    # Fetch authors
    Array(work["authors"]).each do |author_ref|
      author_key = author_ref["key"]
      begin
        author_url  = "https://openlibrary.org#{author_key}.json"
        author_resp = HTTParty.get(author_url)
        next unless author_resp.success?

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
      rescue => e
        puts "⚠️ Failed to fetch author #{author_key}: #{e.message}"
      end
    end
  end
end
