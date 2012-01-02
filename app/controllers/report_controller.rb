class ReportController < ApplicationController
  
  # these are text reports for your ass
  # I'll start these as totals from the beginning of time
  def effort_summary
    project_id = params[:id]
    proj = Project.find( project_id )
    
    efforts = proj.efforts
    
    report_data = []
    total_minutes = 0
    efforts.each do |effort|
      effort.timeentries.each do |entry|
        entry.minutes ? total_minutes += entry.minutes : nil
      end
      taginfos = effort.taginfos.map{ |x| x.name }
      report_data << { :taginfos=>taginfos, :total_minutes=>total_minutes }
    end
    
    render :partial=>"effort_summary", :locals=>{ :report_data=>report_data, :project_id=>project_id }
  end
  
  def tag_summary
    project_id = params[:id]
    proj = Project.find( project_id )

    taginfos = proj.taginfos
    efforts = proj.efforts
    report_data = []
    
    tag_minutes = 0    
    taginfos.each do |taginfo|

      # get the efforts for this taginfo, and total up the minutes across all efforts
      efforts.each do |effort|
        if effort.taginfos.include?(taginfo)
          effort.timeentries.each do |entry|
            entry.minutes ? tag_minutes += entry.minutes : nil
          end
        end
      end
      report_data << { taginfo.name=>tag_minutes }
    end
    
    render :partial=>"tag_summary", :locals=>{ :report_data=>report_data, :project_id=>project_id }
  end
  
  # Creates a report that shows how much time was spent on each effort 
  def effort_report
    project_id = params[:project_id]
    proj = Project.find( project_id )
    
    startDate = Time.now - 1.year
    stopDate = Time.now
    
    results = {}
    proj.efforts.each do |effort|  
      totalEfforts = effort.total_work_as_hash( startDate, stopDate )
      totalEfforts.each_pair do |k, v|
        if v > 0
          results.store( k, v )
        end
      end
    end
    
    dataPoints = []
    keyList = []
    
    if results.size > 1
      keyList = results.keys.sort
      keyList.each do |key|
	dataPoints.push( results[key] )
      end
    end
    
    dataPoints = dataPoints.map{ |x| x / 60 }
    
    # set up the labels
    labels = {}
    for i in 0..dataPoints.size - 1
      labels[i] = keyList[i]
    end
    
    # build the graph
    self.create_graph( project_id, dataPoints, "Efforts", labels, "bar", "Efforts", "Hours", "Effort Totals" )
  end
  
  # Creates a report that shows the number of hours worked on an entire project
  def project_report
    project_id = params[:project_id]
    proj = Project.find( project_id )

    startDate = Time.now - 1.year
    stopDate = Time.now
    results = proj.total_work_as_hash( startDate, stopDate )
    
    # wtf ????
    # why do I need to do this?
    results.delete_if{ |key, val| val == {} }
    
    # pull out the raw minutes
    # format everything as hours
    dataPoints = []
    keyList = []
    if results.size > 1
      keyList = results.keys.sort
      keyList.each do |key|
	dataPoints.push( results[key] )
      end
      dataPoints = dataPoints.map{ |x| x / 60 }
    end

    # build label hash
    labels = {}
    for i in 0..dataPoints.size-1
      labels[i] = keyList[i].strftime("%m/%d")
    end
    
    if labels.size > 7
      for i in 0..labels.size
	if i % 5 != 0
	  labels.delete( i )
	end
      end
    end
    
    colors = ["#0000FF"]
    self.create_graph( project_id, dataPoints, "Total Effort", labels, "line", "Period", "Hours", "Project Report", colors )
  end
  
  def generate_project_report
    render :partial=>"project_report", :locals=>{ :project_id=>params[:id] }
  end
  
  protected
  
  def create_graph( project_id, dataPoints, seriesName, labels, type, x_label, y_label, title, colors=nil )   
    g = nil
    case type
      when 'bar'
	g = Gruff::Bar.new      
      when 'line'
	g = Gruff::Line.new
      when 'pie'
	g = Gruff::Pie.new
    end
    g.theme_pastel()
    g.x_axis_label = x_label
    g.y_axis_label = y_label
    g.title = title
    colors == nil ? nil : g.replace_colors( colors )
    g.data( seriesName, dataPoints )
    g.marker_font_size = 14
    g.labels = labels
    send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "project_graph_#{project_id}.png")   
  end
end