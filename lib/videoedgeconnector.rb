require "videoedge/version"
require 'json'

class VideoEdgeConnector

  attr_accessor :host, :username, :password, :inputs_url, :storage_url, :info_url, :cache_location, :loaded

  def initialize(ve_server, ve_user, ve_password)
    @host = ve_server
    @username = ve_user
    @password = ve_password
    @inputs_url = 'cameras/inputs/'
    @storage_url = 'storage/get_storageset_config/'
    @info_url = 'cameras/camera_info/'
    @cache_location = './output/cameras.yml'
  end

  def get_random
    ('a'..'z').to_a.shuffle[0,8].join
  end

  def get_camera_list
    result = server_call(@inputs_url + "?" + get_random)
    !result["slots"].nil? ? result["slots"] : {}
  end

  def get_camera(id)
    result = server_call(@info_url + id.to_s + "/?" + get_random)
    !result["cam_info"].nil? ? result["cam_info"] : {"cam_info":{}}
  end

  def load_cameras_from_server
    results = []
    cameras = get_camera_list
    cameras.each do |camera|
      detail = {}
      camera_detail = get_camera(camera)
      detail["ip"]         = camera_detail["ip"]
      detail["name"]       = camera_detail["name"]
      detail["recording"]  = camera_detail["record_mode"].to_s == "2" ? "Ok" : "Unknown"
      detail["enabled"]    = camera_detail["cameraEnabled"].to_s == "true" ? "Ok" : "Unknown"
      results.push(detail)
    end
    dump_cache(results)
    results
  end

  def check_cameras(use_cache=false)
    load_cache if use_cache
    results = (@loaded && use_cache) ? load_cache : load_cameras_from_server
    results
  end

  def server_call(api)
    result = "{}"
    uri = URI("http://#{@host}/#{api}")
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth @username, @password
      response = http.request request # Net::HTTPResponse object
      result = response.body
    end
    begin
      JSON.parse(result)
    rescue
      {}
    end
  end

  def dump_cache(cameras_report)
    begin
      file = File.open(@cache_location, "w")
      file.write YAML::dump(cameras_report)
      file.close
      true
    rescue
      false
    end
  end

  def load_cache
    @email_sent = {}
    if(File.exists? @cache_location)
      file = File.open(@cache_location, "rb")
      file_contents = file.read
      contents = YAML::load(file_contents)
      @loaded = true
      contents
    else
      {}
    end
  end

end
