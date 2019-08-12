require 'nokogiri'
require 'httparty'
require 'byebug'
require 'csv'

def scraper
    url = 'https://tecnoblog.net/page/1996/'
    posts = Array.new
    page = 2
    last_page = 1996
       
    while page <=  last_page
        url = "https://tecnoblog.net/page/#{page}/"
        puts url
        unparsed_page = HTTParty.get(url)
        parsed_page = Nokogiri::HTML(unparsed_page)
        post_cards = parsed_page.css('div.grid4 article.bloco')
        post_cards.each do |post_card|
            
          post = {
            title: post_card.css('div.texts a').first.text ,
            author: post_card.css('div.texts a').children[1].text ,
            created_at: post_card.css('div.info').text
          }
          posts << post
          puts "added post #{post[:title]}"
        end    
        import_post(posts,page)   
        page +=1       
    end

    import_posts_to_csv(posts)
    
end

def get_big_post(parsed_page)
    bigpost = parsed_page.css('div.post-big')
    post = {
        title: bigpost.css('a')[2].text ,
        author: bigpost.css('div.info').children[1].text,
        created_at: bigpost.css('div.info').children[0].text
    } 
    
end

def import_posts_to_csv(posts)
    CSV.open("file.csv", "wb") do |csv|
        csv << ["Title", "Author", "Created_at"]
        posts.each do |post|            
            csv << [post[:title],post[:author],post[:created_at]]
        end
    end
end

def import_post(posts,page)
    CSV.open("Files/file#{page}.csv", "wb") do |csv|
      csv << ["Title", "Author", "Created_at"]
      posts.each do |post|            
        csv << [post[:title],post[:author],post[:created_at]]
    end
  end
end


scraper