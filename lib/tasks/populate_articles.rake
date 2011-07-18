  require 'rubygems' 
  require 'open-uri'
  require 'nokogiri'
namespace :add_content do 
  task :msnbc => :environment do
    desc "Fetch Articles From MSNBC ( and sometimes REUTERS)"
  begin
    failed_docs = []
    msnbc_site = Site.find_by_name('MSNBC')
    reuters_site = Site.find_by_name('REUTERS')
    threads = []
    startday =( msnbc_site.articles.maximum(:published ) - 1.week).to_date
    for day in (startday .. Date.today)
    #  threads << Thread.new(a_day) do |day|
    #   puts ' new thread for ' + day.to_s
        begin 
          puts "Opening article list from #{day}"
          fh = open("http://api.msnbc.msn.com/documents/getdocuments?contentType=ar&maxResults=1000&output=XML&startDate=#{day}&endDate=#{day}")
          puts "Opened article list for #{day}"

          puts "Converting article list for #{day}"
          doc = Nokogiri::XML(fh)
          puts "Converted article list for #{day}"
          total = (doc/'Total').inner_html
          sub_threads = []
          puts "iterating through #{total} documents for #{day}"
          (doc/'Document').each_with_index do |ar,index|
          text = ''
          
          begin
	        unless (ar/'DocUri').inner_html.to_s =~ /\Ahttp:\/\/www\.reuters\.com\/article\/id/
            docid = "MSNBC-" + (ar/'DocID').inner_html.to_s
	        else 
    	      docid = 'REUTERS-' + (((ar/'DocUri').inner_html.to_s.sub(/\Ahttp:\/\/www\.reuters\.com\/article\/id/,'')).sub(/\?.*/, '')).to_s
    	      is_reuters = true
    	    end
          next unless docid
          next if docid == "MSNBC-0"
          if Article.find_by_docid(docid)
            STDERR.puts "#{index} of #{total} for #{day} : ERROR article #{docid} already in database"
            next 
          end
	            puts "#{index} of #{total} for #{day}: opening document #{docid}"
	            handle = open((ar/'DocUri').inner_html)
	            article = Nokogiri::HTML(handle)
	            if !is_reuters
                article.search('script').remove
                content = nil
                content ||= (article/'#fullstory').first
                content ||= (article/'.page .i1 .txt').first
                content ||= (article/'div#intelliTXT').first
             	  if content.nil?
             	    puts 'Text no Longer Available' 
             	    next
             	  end
                (content/'p').each {|p|text << p.inner_html}

                msnbc_site.articles.create!( 
                  :title => (ar/'DocTitle').inner_html,
                  :abstract => (ar/'DocAbstract').inner_html,
                  :full_text => text,
                  :published => Time.parse((ar/'DocPublished').inner_html),
                  :placename => (ar/'Location'/'Placename').inner_html,
                  :country   => (ar/'Location'/'Country').inner_html ,
                  :zip => (ar/'Location'/'PostalCode').inner_html.to_i,
                  :latitude => (ar/'Location'/'Latitude').inner_html.to_f,
                  :longitude => (ar/'Location'/'Longitude').inner_html.to_f,
                  :docid => docid,
                  :url => (ar/'DocUri').inner_html
                  )
                  puts "   created  #{index} of #{total} for #{day}"
                elsif is_reuters 
                  text = ''
                  article.search('script').remove
                  content = nil
                  content ||= (article/'span#articleText').first
                  location = (content/'span.location').inner_html
                  (content/'span').remove
                  (content/'a').remove_attr('href')
                  (content/'p').each {|p|text << p.inner_html}
                  
                  a = Article.new
                  a.site = reuters_site                  
                  a.title = (ar/'DocTitle').inner_html
                  a.abstract =(ar/'DocAbstract').inner_html
                  a.full_text = text
                  a.published = Time.parse((ar/'DocPublished').inner_html)
                  a.placename = location
                  a.country   = (ar/'Location'/'Country').inner_html
                  a.docid = docid.to_s
                  a.url = (ar/'DocUri').inner_html
                  a.location_list.add location
                  a.topic_list.add location
                  a.save!
                  puts "   created  #{index} of #{total} for #{day}"
                end             
	            rescue  OpenURI::HTTPError => e
	              STDERR.puts e
	            rescue NoMethodError => nme
	              STDERR.puts 'NoMethodError - '+nme.backtrace. join("\n---" )
	            rescue ActiveRecord::RecordInvalid => ri
	              STDERR.puts (ar/"DocUri").inner_html.to_s + 'Is already in database'
                next
              end
            end
          rescue EOFError
            failed_docs << [day]
          rescue
            STDERR.puts $!.message
            failed_docs << [day]
            next
          ensure  
          end
        end
     # end
      rescue
        raise
      ensure
        STDERR.puts puts failed_docs.inspect
      end
     # threads.each &:join
     end

   

    
    namespace :npr do

      def get_articles(topic, location, topics, country, startpage = 0) 
        begin
	
        npr = Site.find_by_name 'NPR'
        start =( npr.articles.maximum(:published ) - 1.week).to_date
#        for day in (4.months.ago.to_date) .. (Date.today())
          catch :end_of_results do 
          
            page = startpage;
            loop do 
              puts "opening page #{page} since #{start} on #{topic}"
              fh = open("http://api.npr.org/query?id=#{topic}&fields=title,teaser,storyDate,show,text,correction,titles"+
                          "&requiredAssets=text&startDate=#{start}&endDate=#{Date.today}&startNum=#{page * 20}"+
                          "&dateType=story&output=NPRML&numResults=20&apiKey=#{APIKeys.npr}")
              doc = Nokogiri::XML(fh)
              puts 'opened'
              unless (doc/'message').blank?
                puts "end of results found on page #{page}"
                throw :end_of_results 
              end 
                
              (doc/'list/story').each_with_index do |story,index|
                docid = "NPR-" + story.attributes['id'].to_s
                if a = Article.find_by_docid(docid)
	                STDERR.puts "# #{index} from page  #{page} : ERROR article #{docid} already in db"
	                STDERR.puts "updating tags "
	                a.save
	                next 
	              end
                a = Article.new
                
                a.docid = docid
                a.site = npr
                a.url = (story/'link[@type="html"]').inner_text
                a.full_text = (story/'text/paragraph').inner_text
                a.title =  (story/'title').inner_text
                a.sub_title =  (story/'subtitle').inner_text
                a.published = (story/'storyDate').inner_text
                a.abstract = (story/'teaser').inner_text
                a.location_list.add location
                a.topic_list.add location, topics,  :parse => true
                a.placename = location if a.placename.blank?
                a.country = country unless country.blank?
                a.save!
                puts "# #{index} from page  #{page}  created ( #{(story/'storyDate').inner_text} )"
              end #each
              page = page +1
            end# loop
          end #catch
         rescue
          retry
         end
      #  end#for
      end #def
      task :afghanistan => :environment do 
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1149, 'Afghanistan', 'International', 'AF')
      end
      task :africa => :environment do 
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1126, 'Africa', 'International', '')
      end #task
      task :asia => :environment do 
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1125, 'Asia', 'International', '')
      end #task
      task :economy => :environment do 
        desc "Fetch Articles From NPR in this subject area"
       get_articles(1017, '', 'Economy', '')
      end #task
      task :energy => :environment do 
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1131, '', 'Energy', '')
      end #task
      task :education => :environment do 
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1013, '', 'Education', '')
      end #task
      task :enviro => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1025, '', 'Environment', '') 
      end #task
      task :europe => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1124, 'Europe', 'International', '') 
      end #task    
      task :governing => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1123, '', 'Governing', '') 
      end #task   
      task :health => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1128, '', 'Health', '') 
      end #task    
      task :healthcare => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1027, '', 'Healthcare', '') 
      end #task    
      task :latin_america => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1127, 'Latin America', 'International', '') 
      end #task       
      task :national_security => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1122, 'United States', 'National Security, Domestic', 'US') 
      end #task    
      task :news => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1001, '', 'News', '') 
      end #task  
      task :politics => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1014, '', 'Politics', '') 
      end #task 
      task :religion => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1016, '', 'Religion', '') 
      end #task   
      task :research_news => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1024, '', 'Research News', '') 
      end #task      
      task :science => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1007, '', 'Science', '') 
      end #task     
      task :space => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1024, '', 'Space', '') 
      end #task               
      task :technology => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1019, '', 'Technology', '') 
      end #task             
      task :war_impact => :environment do
        desc "Fetch Articles From NPR in this subject area"
         get_articles(1078, '', 'The Impact of War', '') 
      end #task       
      task :us => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1003, 'United States', 'US News, Domestic, News', 'US') 
      end #task      
      task :world => :environment do
        desc "Fetch Articles From NPR in this subject area"
        get_articles(1004, 'World', 'World News, International, News', '') 
      end #task      
      task :all => :environment do 
        desc "Fetch Articles From NPR for all topics "
        get_articles(1149, 'Afghanistan', 'International', 'AF')
        get_articles(1126, 'Africa', 'International', '')
        get_articles(1125, 'Asia', 'International', '')
        get_articles(1017, '', 'Economy', '')
        get_articles(1131, '', 'Energy', '')
        get_articles(1013, '', 'Education', '')
        get_articles(1025, '', 'Environment', '') 
        get_articles(1124, 'Europe', 'International', '') 
        get_articles(1123, '', 'Governing', '') 
        get_articles(1128, '', 'Health', '') 
        get_articles(1027, '', 'Healthcare', '') 
        get_articles(1127, 'Latin America', 'International', '') 
        get_articles(1122, 'United States', 'National Security, Domestic', 'US') 
        get_articles(1001, '', 'News', '') 
        get_articles(1014, '', 'Politics', '') 
        get_articles(1016, '', 'Religion', '') 
        get_articles(1024, '', 'Research News', '') 
        get_articles(1007, '', 'Science', '') 
        get_articles(1024, '', 'Space', '') 
        get_articles(1019, '', 'Technology', '') 
        get_articles(1078, '', 'The Impact of War', '') 
        get_articles(1003, 'United States', 'US News, Domestic, News', 'US') 
        get_articles(1004, 'World', 'World News, International, News', '') 

      end
    end    #napace npr
    namespace :guardian do
        SECTIONS='-lifeandstyle,-leeds,-katine,-music,-culture,-local-government-network,-stage,-help,-extra,-guardian-professional,-film,-artanddesign,-community,-cardiff,-crosswords,-sport,-housing-network,-travel/offers,-books,-weather,-info,-voluntary-sector-network,-football,-edinburgh,-travel,-local'
        FIELDS = 'headline,trailText,byline,body'
        PAGE_SIZE = 50
      def guardian_url(day, start_page)
        uri = "http://content.guardianapis.com/search?section=#{SECTIONS}&from-date=#{day}"+
              "&to-date=#{day}&page=#{start_page}&page-size=#{PAGE_SIZE}&order-by=newest"+
              "&format=xml&show-fields=#{FIELDS}&api-key=#{APIKeys.guardian}"
        return uri
      end
    task :get => :environment do
        desc "Fetch Articles From TheGuardian"
  # begin
        guardian = Site.find_by_name 'GUARDIAN'
        startday =( guardian.articles.maximum(:published ) - 1.week).to_date
        for day in (startday .. Date.today)
          
            start_page = 1
            puts "opening page 1 of results for #{day}"
            puts "yo"

            fh = open(guardian_url(day,start_page))
            puts "opened"
            puts "parsing"
            doc = Nokogiri::XML(fh)
            puts "parsed"
            total_pages = (doc/"response").first.attributes['pages'].value.to_i
            puts "total pages " + total_pages.to_s
            start_page.upto(total_pages) do |page|
              puts "opening page #{page} of #{total_pages} of results for #{day}"
              fh = open(guardian_url(day,start_page))
              doc = Nokogiri::XML(fh)
              puts 'opened'
              (doc/'results/content').each_with_index do |story,index|
                docid = ("GUARDIAN-" + story.attributes['id'].value.to_s)
                puts "set docid"
                if Article.find_by_docid(docid)
	                STDERR.puts "\# #{index} from page  #{page} : ERROR article #{docid} already in db"
	                next
	              end
                if (((story/'field[@name="body"]').blank?) ||( (story/'field[@name="body"]').inner_html == "<\!\-\- Redistribution rights for this field are unavailable \-\-\>"))
                  STDERR.puts "text no longer available"
                  next
                end
                puts "creating article"
                a = Article.new

                a.docid = docid
                a.site = guardian
                a.url = (story.attributes['web-url']).inner_text
                a.title =  (story/'field[@name="headline"]').inner_text
                a.sub_title =  (story/'field[@name="trail-text"]').inner_text
                a.published = (story.attributes['web-publication-date']).inner_text.to_date
                (story/'field[@name="body"]/div.gu_advert').remove
                (story/'field[@name="body"]/img').remove

                a.full_text = (story/'field[@name="body"]').inner_text
                a.author = (story/'field[@name="byline"]').inner_text
                a.topic_list.add(story.attributes['section-name'].value, :parse => false)
                a.save!
                puts "# #{index} from page  #{page}  created ( #{a.published()} )"
              end

              #each
              
            end# loop
        end

        # rescue
        #  retry
        # end
        
    end
    end
   end # namespace add content
 

