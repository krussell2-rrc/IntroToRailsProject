require 'httparty'

subjects = [ "horror", "fantasy", "romance", "poetry", "thriller" ]

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

      description = if work_data["description"].present?
                    if work_data["description"].is_a?(Hash)
                        work_data["description"]["value"]
                    else
                      work_data["description"]
                    end
      else
                  "Book description not found"
      end

      # Create the Book records
      book = Book.find_or_create_by(work_key: work_key) do |b|
        b.title = title
        b.description = description
        b.subject = book_subject
        b.first_publish_year = first_publish_year
        b.edition_count = edition_count
        b.cover_identifier = cover_identifier
      end

        # Fetch the author(s) for this work
        authors = work["authors"]

        if authors.size == 1
          # Only one author in the array
          author_ref = authors.first
          author_key = author_ref["key"]

          author_url = "https://openlibrary.org#{author_key}.json"
          author_response = HTTParty.get(author_url)

          if author_response.success?
            author_data = JSON.parse(author_response.body)
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

            author = Author.find_or_create_by(author_key: author_key) do |a|
              a.author_name = author_name
              a.biography = biography
            end
            book.authors << author unless book.authors.include?(author)
          end

        elsif authors.size > 1
          # When there are multiple authors
          names = authors.map { |a| a["name"] }

          if names.uniq.size == 1
            # Since OpenLibrary API can return the same author multiple times.
            # Check to see if they are multiple hashes, if so check if their names are all the same.
            # If all the names are the same, grab the first author key.
            author_ref = authors.first
            author_key = author_ref["key"]

            author_url = "https://openlibrary.org#{author_key}.json"
            author_response = HTTParty.get(author_url)

            if author_response.success?
              author_data = JSON.parse(author_response.body)
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

              author = Author.find_or_create_by(author_key: author_key) do |a|
                a.author_name = author_name
                a.biography = biography
              end
              book.authors << author unless book.authors.include?(author)
            end

          else
            # Different authors: iterate over each one
            authors.each do |author_ref|
              author_key = author_ref["key"]

              author_url = "https://openlibrary.org#{author_key}.json"
              author_response = HTTParty.get(author_url)

              if author_response.success?
                author_data = JSON.parse(author_response.body)
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

                author = Author.find_or_create_by(author_key: author_key) do |a|
                  a.author_name = author_name
                  a.biography = biography
                end
                book.authors << author unless book.authors.include?(author)
              end
            end
          end
        end
    end
  end
end
