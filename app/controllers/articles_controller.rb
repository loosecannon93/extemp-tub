class ArticlesController < ApplicationController
  before_filter :require_user
  # GET /articles
  # GET /articles.xml
  def index
    page = params[:page] || 1
    @articles = Article.paginate :all, :include => :site, :page => page, :order => 'published DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end
  def search
      page = params[:page] || 1
      per_page = params[:per_page] || Article.per_page
     @query = params[:direct_query].to_s if params[:direct_query]
     @query ||= params[:search][:query].to_s
     #@search_options = eval(params[:search_options])
     @articles = Article.search(@query, :page => page , :per_page => per_page)
     @current_user.searches.create(:query => @query)
  
    respond_to do |format|
      format.html # search.html.erb
      format.xml  { render :xml => @articles }
    end
  end
  def advanced
    page = params[:page] || 1
    @base = params[:query][:any] || ''
    @conditions = {}
    @conditions[:title]     = params[:conditions][:title] unless params[:conditions][:title].blank?
    @conditions[:sub_title] = params[:conditions][:sub_title] unless params[:conditions][:sub_title].blank?
    @conditions[:abstract]  = params[:conditions][:abstract] unless params[:conditions][:abstract].blank?
    @conditions[:full_text] = params[:conditions][:full_text] unless params[:conditions][:full_text].blank?
    @conditions[:url]       = params[:conditions][:url] unless params[:conditions][:url].blank?
    @conditions[:placename] = params[:conditions][:placename] unless params[:conditions][:placename].blank?
    
    unless ( params[:query][:lat].blank? || params[:query][:lat_delta].blank? )
      @latitude = { :latitude => 
        (params[:query][:lat].to_f - params[:query][:lat_delta].to_f)..
        (params[:query][:lat].to_f + params[:query][:lat_delta].to_f )
        }
    else
      @latitude = {}
    end
    unless ( params[:query][:long].blank? || params[:query][:long_delta].blank?)
    @longitude = {:longitude =>
      (params[:query][:long].to_f - params[:query][:long_delta].to_f )  .. 
      (params[:query][:long].to_f + params[:query][:long_delta].to_f ) 
      }
    else
      @longitude = {}
    end
    unless ( params[:query][:published_start].blank? || params[:query][:published_end].blank?)
    @start = Date.new( params[:query][:published_start][:year], 
                       params[:query][:published_start][:month],
                       params[:query][:published_start][:day])
    @end = Date.new(   params[:query][:published_end][:year], 
                       params[:query][:published_end][:month],
                       params[:query][:published_end][:day])

    @published = {:published => @start..@end}
    else
      @published = {}
    end
    @with = {}
    @with.merge! @longitude
    @with.merge! @latitude    
    @with.merge! @published    
    @with[:zip] = params[:with][:zip] unless params[:with][:zip].blank?
    @with[:country] = params[:with][:country] unless params[:with][:country].blank?
    @with[:site_id] = params[:with][:site_id] unless params[:with][:site_id].blank?
    @articles = Article.search(@base, :page => page, :conditions => @conditions, :with => @with )

    respond_to do |format|
      format.html { render :action => :search  }# search.html.erb
      format.xml  { render :xml => @articles }
    end
  end
  
  
  
  def new_advanced 
  @site = Site.all
   end
  def new_search
	  @count = Article.count
	  render :layout => false
  end


  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = Article.find(params[:id])
    @search = nil
    if request.referer =~ /\A.*\/search\?/
      @search = @current_user.searches.last
    end
    @reading = @current_user.readings.create :article => @article,  :search => @search

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = Article.new
    @sites = Site.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/1/edit
  def edit
      @sites = Site.all
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.xml
  def create
    @article = Article.new(params[:article])

    respond_to do |format|
      if @article.save
        format.html { redirect_to(@article, :notice => 'Article was successfully created.') }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to(@article, :notice => 'Article was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(articles_url) }
      format.xml  { head :ok }
    end
  end
end
