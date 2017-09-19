require 'scraperwiki'
require 'mechanize'

info_url = "https://www.blacktown.nsw.gov.au/Plan-build/Stage-1-find-out/Development-on-notification"
url = "https://services.blacktown.nsw.gov.au/webservices/scm/default.ashx?itemid=890&stylesheet=xslt/DAOnline.xslt"
comment_url = "mailto:council@blacktown.nsw.gov.au"

agent = Mechanize.new
page = agent.get(url)

xml = Nokogiri::XML(page.body)
xml.xpath('//DevelopmentsOnNotifications/DevelopmentsOnNotification').each do |app|
    description = app.xpath('Notes').inner_text.size > app.xpath('Activity').inner_text.size ? app.xpath('Notes').inner_text : app.xpath('Activity').inner_text

    record = {
      "council_reference" => app.xpath('ApplicationID').inner_text,
      "address" => app.xpath('PrimaryAddress').inner_text,
      "description" => description.gsub(/\s+/, ' '),
      "info_url"    => info_url,
      "communt_url" => comment_url,
      "date_scraped" => Date.today.to_s,
      "date_received" => DateTime.parse(app.xpath('LodgementDate').inner_text).to_date.to_s
    }

  if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
    puts "Saved record " + record['council_reference']
#     puts record
    ScraperWiki.save_sqlite(['council_reference'], record)
  else
    puts "Skipping already saved record " + record['council_reference']
  end

end
