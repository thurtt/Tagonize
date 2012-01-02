module ReportHelper
    def project_report_tag(opts={})
        "<img src=\"/report/project_report\?project_id=#{opts[:project_id]}\" width=\"#{opts[:width]}\" height=\"#{opts[:height]}\" onload=\"#{opts[:onload]}\" alt=\"Project Report\" border=0/>"
    end
    
    def effort_report_tag( opts={} )
        "<img src=\"/report/effort_report\?project_id=#{opts[:project_id]}\" width=\"#{opts[:width]}\" height=\"#{opts[:height]}\" onload=\"#{opts[:onload]}\" alt=\"Effort Report\" border=0/>"
    end
end
