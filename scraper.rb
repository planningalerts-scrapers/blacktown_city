require 'scraperwiki'
require 'mechanize'

    info_url = "http://www.blacktown.nsw.gov.au/Planning_and_Development/Development_Assessment/Development_Online/Developments_on_Notification"
    comment_url = "mailto:council@blacktown.nsw.gov.au"

    agent = Mechanize.new
    page = agent.get("http://www.blacktown.nsw.gov.au/Planning_and_Development/Development_Assessment/Development_Online/Developments_on_Notification")
    

    page.search(".body-content table").map do |app|
    record = {}

        app.search("tr").each do |row|
            if row.inner_text.index('Application: ') 
                text = row.inner_text.strip.split('Application: ')[1]
                record.merge!('council_reference' => text.split(',')[0], 'address' => text.split('[+]')[1])
            end

            if row.inner_text.index('Activity: ')
                record.merge!('description' => row.inner_text.strip.split('Activity: ')[1])
            end

            if row.inner_text.index('Lodgement Date: ')
                record.merge!('date_received' => Date.parse(row.inner_text.strip.split('Lodgement Date: ')[1], '%Y-%m-%d').to_s)
            end
        end
        
        record.merge!('date_scraped' => Date.today.to_s, 
                      'info_url' => info_url, 
                      'comment_url' => comment_url)
                      
        if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
            ScraperWiki.save_sqlite(['council_reference'], record)
            puts "Saved record " + record['council_reference']              
        else
            puts "Skipping already saved record " + record['council_reference']
        end
    end

