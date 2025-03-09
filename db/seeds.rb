require 'httparty'

subjects = [ "Horror", "Fantasy", "Romance", "Poetry", "Thriller" ]

subjects.each do |subject|
  # Defining API URL for different subjects
  encoded_term = URI.encode_www_form_component(subject)
  url = "https://openlibrary.org/subjects/#{encoded_term}.json?limit=50"

  # Making the request
  response = HTTParty.get(url)

  # Parsing the response JSON
  data = JSON.parse(response.body)

  if data["works"]
    data["works"].each do |work|
      title = work["title"] || "Unknown Title"
      first_publish_year = work["first_publish_year"]
      edition_count = work["edition_count"] || 0
      cover_identifier = work["cover_id"]
    end
  end
end
