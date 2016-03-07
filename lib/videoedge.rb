require "videoedge/version"
require 'json'
require './lib/videoedgeconnector.rb'

module Videoedge

  def self.get_cameras_list(host,username,password)
    ve = VideoEdge.new(host,username,password)
    ve.get_cameras_list
  end

  def self.get_camera_info(host,username,password)
    ve = VideoEdge.new(host,username,password,cam_id)
    ve.get_camera(id)
  end

end
