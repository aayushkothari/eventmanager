require "csv"
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

puts "Event Manager Initialized!"
if not File.exist? "event_attendees.csv"
	puts "File doesn't exist"
else
	#contents=File.read "event_attendees.csv"
	#lines=File.readlines "event_attendees.csv"
	contents=CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
end
#puts contents
'''lines[0..-1].each do |line|
	columns=line.split(",")
	puts columns
	name=columns[2]
	#puts name
end
'''
def clean_zip(zip)
	'''if zip.nil?
    	zip = "00000"
  	elsif zip.length < 5
    	zip = zip.rjust 5, "0"
  	elsif zip.length > 5
    	zip = zip[0..4]
    else
    	zip
  	end'''
  	zip.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone)
    number=""
	#collecting digits from given string 'phone'
	for i in 0...phone.length
    	if ([*48..57].include?(phone[i]))==true 
        	number+=(phone[i]-48).to_s
		end
	end
	if (number.length<10) || (number.length>11)
		number="0000000000" #representing a bad number
	elsif (number.length==11) 
        if ((number[0]-48) == 1)
		    number=number[1..-1]
	    else number="0000000000"
        end 
	end
		#return a well-formed number 
		return "("+number[0..2]+")"+number[3..5]+"-"+number[6..9]

end 

def legs_by_zip(zip)
	legs=Sunlight::Congress::Legislator.by_zipcode(zip)
	#leg_names=legs.collect {|leg| "#{leg.first_name} #{leg.last_name}"}
	#leg_names.join(", ")
end

def save_thank_you(id,form_letter)
	Dir.mkdir("output") unless Dir.exists? "output"
	filename="output/thanks_#{id}.html"
	File.open(filename,'w') do |file|
		file.puts form_letter
	end
end

def best_hour(dates)
	hours=[]
	hour_analysis={}

	for date in dates
		hours<<date.strftime("%k").to_i
		days<<date.to_date
	end

	max_freq=hours.count(hours[0])
	for hour in hours
		hour_analysis[hour]=hours.count(hour)
		if hours.count(hour) > max_freq
			max_freq = hours.count(hour)
		end
	end
    
	#Tabulating analysis 
	puts "","Hour\t\t\tRegistrations","_"*4+"\t\t\t"+"_"*13
	hour_analysis.each do |hour,count|
		if count==max_freq
			puts "#{hour}:00"+"-"+"#{hour+1}:00 (Peak hour)\t\t#{count}"
		else
			puts "#{hour}:00"+"-"+"#{hour+1}:00\t\t\t#{count}"
		end
	end
end

def best_days(dates)
	days=[]
	weekday_analysis={}
	week=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Sat.","Sunday"]
	for date in dates
		days<<date.to_date.wday
	end
	max_freq=days.count(days[0])

	for day in days
		weekday_analysis[day]=days.count(day)
		if days.count(day) > max_freq
			max_freq=days.count(day)
		end
	end
	puts "","Weekday Analysis"
	puts "","Weekday\t\t\tRegistrations","_"*7+"\t\t\t"+"_"*13
	weekday_analysis.each do |day,count|
		if count==max_freq
			puts "#{week[day]} (Peak day)\t\t#{count}"
		else
			puts "#{week[day]}\t\t\t\t#{count}"
		end
	end
end

#template_letter=File.read "form_letter.html"
template_letter=File.read "form_letter.erb"
erb_template=ERB.new template_letter
reg_dates=[]

contents.each do |row|
	id=row[0]
	name = row[:first_name]
	zipcode = clean_zip(row[:zipcode])
	leg_names=legs_by_zip(zipcode)
	phone=row[:homephone]
	reg_dates<<DateTime.strptime(row[:regdate],"%m/%d/%Y %H:%M")
	
	'''Iteration:Clean Phone Numbers. Uncomment to view results'''
	#puts clean_phone(phone)

	#puts "#{name} #{zipcode} #{leg_names}"
	form_letter=erb_template.result(binding)
	#puts form_letter
	save_thank_you(id,form_letter)

end

'''Iteration:Time Targeting. Uncomment to view analysis'''
#best_hour(reg_dates)

'''Iteration:Day Of The Week Targeting. Uncomment to view analysis'''
#best_days(reg_dates)
