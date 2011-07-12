 
    namespace :update_tags do
      task :add_placename => :environment do 
        puts 'retrieving articles'
        articles = Article.find :all ,:select => 'id, country, placename', :conditions => "placename != '' or country != '' "
        puts 'retrived, begining processing'
        articles.each_with_index do |art, index|
          if art.country != '-1' or art.placename != 'POINT EMPTY'
            art.location_list = " #{art.country} , #{art.placename}"
          elsif art.country == '-1'
            art.location_list = "#{art.placename}"
          elsif art.placename == 'POINT EMPTY' 
            art.location_list = "#{art.location}"
          end
          art.save(false)
          puts index 
        end
      end
    end   
       
  
