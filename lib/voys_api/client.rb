require 'csv'
require 'mechanize'
require 'fileutils'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/try'
# VoysApi exports voys.nl call list..
class VoysApi::Client

  VOYS_HOST = 'mijn.voys.nl'

  def initialize(username, password)
    @username = username
    @password = password
  end

  def logged_in?
    @logged_in || false
  end

  def login
    return true if @logged_in
    page = agent.get("https://#{VOYS_HOST}/user/login/")
    login_form = page.form
    login_form.fields.detect {|field| field.name == 'this_is_the_login_form'} || raise(VoysApi::AuthenticationError, "Could not find the login form!")
    login_form.field_with(:name => "username").value = @username
    login_form.field_with(:name => "password").value = @password
    login_result = agent.submit login_form
    if (login_result.form && login_result.form.fields.detect {|field| field.name == 'this_is_the_login_form'})
      # We're still on the login page!
      raise(VoysApi::AuthenticationError, "Error logging in!")
    end
    @logged_in = true
  end

  # Options:
  #   period_from: '2013-01-01' (you can also pass a Time object)
  #   period_to: '2013-01-18' (you can also pass a Time object)
  #   inboundoutbound: 0
  #   totals: 0
  #   aggregation: 0
  #   search_query: nil
  #   reset_filter: false
  #   page_number: nil
  #
  # Empty options returns everything.
  def raw_export(options = {})
    login if not logged_in?

    options = convert_options(options)

    result = agent.post('/cdr/export', options)
    result.body
  end

  def html_export(options = {})
    login if not logged_in?

    options = {
        period_from: nil,
        period_to: nil,
        inboundoutbound: 0,
        totals: 0,
        aggregation: 0,
        recordings: 0,
        page: 1
      }.merge(options)
    options = convert_options(options)

    results = []
    page_number = 1
    begin
      options[:page] = page_number
      puts "Page #{page_number}"

      page = agent.get("/cdr?#{options.to_param}")
      rows = page.search('table tbody tr')
      rows.each do |row|
        cols = row.search('td')

        result = {}
        result[:date] = cols[2].inner_text.strip
        result[:inbound__outbound] = cols[3].inner_text.strip
        result[:duration] = cols[5].inner_text
        source = result[:source] = cols[6].inner_text.strip
        destination = result[:destination] = cols[7].inner_text.strip
        recording = result[:recording] = cols[9].at('.jp-embedded').try(:[], 'data-source-wav')
        puts result.inspect

        # Download all recordings
        if recording
          time = Time.parse(result[:date])
          recording_filename = "recordings/#{time.strftime("%Y%m%d_%H%M")}-#{source}-#{destination}.wav"
          FileUtils.mkdir_p(File.dirname(recording_filename))
          get_recording(recording, recording_filename)
        end

        results << result
      end
      page_number += 1
    end until page.at('.pagination a.next').nil?
    return results
  end

  def get_recording(recording_path, filename = nil)
    login if not logged_in?

    if recording_path =~ /(\d+)\/?$/
      recording_id = $1
      filename ||= "#{recording_id}.wav"
      agent.get(recording_path).save(filename)
      return filename
    end
  end

  # Returns CSV::Table of calls.
  # NOTE:
  #  Date and time values are in +0200 timezone but set to UTC
  #  To fix use row[:date].change(:offset => "+0200")
  def export(options = {}, csv_options = {})
    csv_options = {col_sep: ';', converters: [:date_time], headers: :first_row, header_converters: :symbol}.merge(csv_options)
    export = CSV.parse(raw_export(options), csv_options)
    return export
  rescue CSV::MalformedCSVError => exception
    raise exception, "#{exception.message}\nCSV:\n#{raw_export}"
  end

  def logout
    agent.get("https://#{VOYS_HOST}/user/logout/")
  end

private

  def convert_options(options)
    converted_options = options.clone # deep clone?

    # convert options
    converted_options[:period_from] = options[:period_from].strftime("%Y-%m-%d") if options[:period_from] && !options[:period_from].is_a?(String)
    converted_options[:period_to] = options[:period_to].strftime("%Y-%m-%d") if options[:period_to] && !options[:period_to].is_a?(String)

    return converted_options
  end

  def agent
    return @agent if not @agent.nil?
    @agent = Mechanize.new
    @agent.pluggable_parser.default = Mechanize::Download
    return @agent
  end

end