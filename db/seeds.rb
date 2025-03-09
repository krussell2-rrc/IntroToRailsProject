require 'httparty'

subjects = [ "Horror", "Fantasy", "Romance", "Poetry", "Thriller" ]

subjects.each do |subject|
  # Define the API URL for different subjects
  encoded_term = URI.encode_www_form_component(subject)
  url = "https://openlibrary.org/subjects/#{encoded_term}.json?limit=50"

  # Make the request
  response = HTTParty.get(url)

  # Parse the response JSON
  data = JSON.parse(response.body)

  if data["works"]
    # Fetch data about the book from the Subject API
    data["works"].each do |work|
      title = work["title"] || "Unknown Title"
      first_publish_year = work["first_publish_year"]
      edition_count = work["edition_count"] || 0
      cover_identifier = work["cover_id"]
      book_subject = subject

      # Use the work key to fetch the description from the Works API
      work_key = work["key"]
      work_url = "https://openlibrary.org#{work_key}.json"
      work_response = HTTParty.get(work_url)
      work_data = JSON.parse(work_response.body)

      description = if work_data["description"].is_a?(Hash)
                      work_data["description"]["value"]
      else
                      work_data["description"]
      end

      # Create the Book record
      book = Book.create!(
        title: title,
        description: description,
        subject: book_subject,
        first_publish_year: first_publish_year,
        edition_count: edition_count,
        cover_identifier: cover_identifier,
        work_key: work_key
      )

      # Fetch the author(s) for this work
      work["authors"].each do |author_ref|
        author_key = author_ref["key"]
        author_url = "https://openlibrary.org#{author_key}.json"
        author_response = HTTParty.get(author_url)

        if author_response.success?
          author_data = JSON.parse(author_response.body)
          # author_data is a single hash representing the author

          author_name = author_data["name"]
          biography = if author_data["bio"].present?
                        if author_data["bio"].is_a?(Hash)
                          author_data["bio"]["value"]
                        else
                          author_data["bio"]
                        end
          else
                        "Author biography not found"
          end

        end
      end
    end
  end
end
