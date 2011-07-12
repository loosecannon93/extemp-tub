task :msnbc_prefix => :environment do
  puts 'gettign articles'


  arts = Article.find :all, :select => 'id, docid', :conditions => 'site_id = 1' 
    puts 'got em'
  arts.each_with_index do |art,index|
  next if art.docid.to_s =~ /\AMSNBC/ or art.docid.to_s =~ /\ANPR/
    art.update_attribute(:docid, "MSNBC-#{art.docid}")
  #  art.save(false)
    puts index
  end
  end
