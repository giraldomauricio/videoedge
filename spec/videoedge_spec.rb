require 'spec_helper'

describe VideoEdgeConnector do

  context 'VideoEdgeConnector' do

    it 'has the configuration needed' do
      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')
      expect(ve.host.nil?).to be false
      expect(ve.username.nil?).to be false
      expect(ve.password.nil?).to be false
      expect(ve.inputs_url.nil?).to be false
      expect(ve.storage_url.nil?).to be false
      expect(ve.info_url.nil?).to be false
      expect(ve.cache_location.nil?).to be false
    end

    it 'checks the randomizer' do
      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')
      rnd1 = ve.get_random
      rnd2 = ve.get_random
      expect(rnd1).not_to eq(rnd2)
    end

    it 'pulls a list of the available cameras' do
      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')

      allow(ve).to receive(:get_random).and_return("a_random_string")

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/inputs/?a_random_string").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => '{"slots": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]}', :headers => {})

      list = ve.get_camera_list

      expect(list.count).to eq(11)

    end

    it 'pulls the info from a specific camera' do
      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')

      allow(ve).to receive(:get_random).and_return("a_random_string")

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/camera_info/3/?a_random_string").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => '{"cam_info": {"logical_id": "114c05cc-9353-556c-bf27-9c165de62a1b", "associated_text": [], "ip": "10.21.200.100", "arch_mode": 0, "firmware": "AD00-00-17-04", "record_mode": 2, "cameraEnabled": true, "input": 0, "scheduler_enabled": false, "auto_arch_enabled": false, "analytics_mode": 1, "streams_unknown": false, "max_streams": 2, "arch_scheduler_enabled": false, "is_onvif": 0, "stream_options": {"stream_1": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}, "stream_0": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}}, "motion_sensitivity": 3, "name": "6th Floor POS Deployment", "associated_audio": "", "is_firmware_supported": true, "auto_arch_valid": false, "streams": {"stream_1": {"res": "CIF", "is_record_stream": false, "is_live_stream": false, "is_analytics_stream": true, "codec": "MJPEG", "fps": 7, "is_alarm_stream": false}, "stream_0": {"res": "1280x720", "is_record_stream": true, "is_live_stream": true, "is_analytics_stream": false, "codec": "H264", "fps": 10, "is_alarm_stream": true}}, "model": "American Dynamics ADCi610LT-D113"}}', :headers => {})

      camera = ve.get_camera(3)
      expect(camera['logical_id']).to eq("114c05cc-9353-556c-bf27-9c165de62a1b")

    end

    it 'does a graceful ending if the camera info returns an unidentified response' do
      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')

      allow(ve).to receive(:get_random).and_return("a_random_string")

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/camera_info/3/?a_random_string").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => 'foo', :headers => {})

      camera = ve.get_camera(3)
      expect(camera['logical_id']).to be_nil

    end

    it 'does a graceful ending if the camera info returns an server error' do
      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')

      allow(ve).to receive(:get_random).and_return("a_random_string")

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/camera_info/3/?a_random_string").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => [500, "Internal Server Error"])

      camera = ve.get_camera(3)
      expect(camera['logical_id']).to be_nil

    end

    it 'does a graceful ending if the api returns an unidentified response' do
      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')

      allow(ve).to receive(:get_random).and_return("a_random_string")

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/inputs/?a_random_string").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => 'foo', :headers => {})

      list = ve.get_camera_list

      expect(list.count).to eq(0)

    end

    it 'does a graceful ending if the server comes with an error' do
      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')

      allow(ve).to receive(:get_random).and_return("a_random_string")

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/inputs/?a_random_string").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => [500, "Internal Server Error"])

      list = ve.get_camera_list

      expect(list.count).to eq(0)

    end

    it 'return the status of all the available cameras' do

      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')

      allow(ve).to receive(:get_random).and_return("a_random_string")

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/inputs/?a_random_string").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => '{"slots": [0, 1, 2]}', :headers => {})

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/camera_info/0/?a_random_string").
            with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(:status => 200, :body => '{"cam_info": {"logical_id": "114c05cc-9353-556c-bf27-9c165de62a1b", "associated_text": [], "ip": "10.21.200.100", "arch_mode": 0, "firmware": "AD00-00-17-04", "record_mode": 2, "cameraEnabled": true, "input": 0, "scheduler_enabled": false, "auto_arch_enabled": false, "analytics_mode": 1, "streams_unknown": false, "max_streams": 2, "arch_scheduler_enabled": false, "is_onvif": 0, "stream_options": {"stream_1": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}, "stream_0": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}}, "motion_sensitivity": 3, "name": "Reception Area", "associated_audio": "", "is_firmware_supported": true, "auto_arch_valid": false, "streams": {"stream_1": {"res": "CIF", "is_record_stream": false, "is_live_stream": false, "is_analytics_stream": true, "codec": "MJPEG", "fps": 7, "is_alarm_stream": false}, "stream_0": {"res": "1280x720", "is_record_stream": true, "is_live_stream": true, "is_analytics_stream": false, "codec": "H264", "fps": 10, "is_alarm_stream": true}}, "model": "American Dynamics ADCi610LT-D113"}}', :headers => {})

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/camera_info/1/?a_random_string").
               with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => '{"cam_info": {"logical_id": "114c05cc-9353-556c-bf27-9c165de62a1c", "associated_text": [], "ip": "10.21.200.101", "arch_mode": 0, "firmware": "AD00-00-17-04", "record_mode": 2, "cameraEnabled": true, "input": 0, "scheduler_enabled": false, "auto_arch_enabled": false, "analytics_mode": 1, "streams_unknown": false, "max_streams": 2, "arch_scheduler_enabled": false, "is_onvif": 0, "stream_options": {"stream_1": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}, "stream_0": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}}, "motion_sensitivity": 3, "name": "Parking Lot", "associated_audio": "", "is_firmware_supported": true, "auto_arch_valid": false, "streams": {"stream_1": {"res": "CIF", "is_record_stream": false, "is_live_stream": false, "is_analytics_stream": true, "codec": "MJPEG", "fps": 7, "is_alarm_stream": false}, "stream_0": {"res": "1280x720", "is_record_stream": true, "is_live_stream": true, "is_analytics_stream": false, "codec": "H264", "fps": 10, "is_alarm_stream": true}}, "model": "American Dynamics ADCi610LT-D113"}}', :headers => {})

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/camera_info/2/?a_random_string").
            with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(:status => 200, :body => '{"cam_info": {"logical_id": "114c05cc-9353-556c-bf27-9c165de62a1d", "associated_text": [], "ip": "10.21.200.102", "arch_mode": 0, "firmware": "AD00-00-17-04", "record_mode": 2, "cameraEnabled": true, "input": 0, "scheduler_enabled": false, "auto_arch_enabled": false, "analytics_mode": 1, "streams_unknown": false, "max_streams": 2, "arch_scheduler_enabled": false, "is_onvif": 0, "stream_options": {"stream_1": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}, "stream_0": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}}, "motion_sensitivity": 3, "name": "Server Room", "associated_audio": "", "is_firmware_supported": true, "auto_arch_valid": false, "streams": {"stream_1": {"res": "CIF", "is_record_stream": false, "is_live_stream": false, "is_analytics_stream": true, "codec": "MJPEG", "fps": 7, "is_alarm_stream": false}, "stream_0": {"res": "1280x720", "is_record_stream": true, "is_live_stream": true, "is_analytics_stream": false, "codec": "H264", "fps": 10, "is_alarm_stream": true}}, "model": "American Dynamics ADCi610LT-D113"}}', :headers => {})

      result = ve.check_cameras()

      expect(result.count).to eq(3)
      expect(result[0]["ip"]).to eq("10.21.200.100")
      expect(result[1]["ip"]).to eq("10.21.200.101")
      expect(result[2]["ip"]).to eq("10.21.200.102")
      expect(result[0]["name"]).to eq("Reception Area")
      expect(result[1]["name"]).to eq("Parking Lot")
      expect(result[2]["name"]).to eq("Server Room")
      expect(result[0]["recording"]).to eq("Ok")
      expect(result[1]["recording"]).to eq("Ok")
      expect(result[2]["recording"]).to eq("Ok")
      expect(result[0]["enabled"]).to eq("Ok")
      expect(result[1]["enabled"]).to eq("Ok")
      expect(result[2]["enabled"]).to eq("Ok")

    end

    it 'saves to the cache' do

      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')
      ve.cache_location = "./spec/output/cameras1.yml"

      allow(ve).to receive(:get_random).and_return("a_random_string")

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/inputs/?a_random_string").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => '{"slots": [0, 1]}', :headers => {})

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/camera_info/0/?a_random_string").
            with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(:status => 200, :body => '{"cam_info": {"logical_id": "114c05cc-9353-556c-bf27-9c165de62a1b", "associated_text": [], "ip": "10.21.200.100", "arch_mode": 0, "firmware": "AD00-00-17-04", "record_mode": 2, "cameraEnabled": true, "input": 0, "scheduler_enabled": false, "auto_arch_enabled": false, "analytics_mode": 1, "streams_unknown": false, "max_streams": 2, "arch_scheduler_enabled": false, "is_onvif": 0, "stream_options": {"stream_1": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}, "stream_0": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}}, "motion_sensitivity": 3, "name": "Reception Area", "associated_audio": "", "is_firmware_supported": true, "auto_arch_valid": false, "streams": {"stream_1": {"res": "CIF", "is_record_stream": false, "is_live_stream": false, "is_analytics_stream": true, "codec": "MJPEG", "fps": 7, "is_alarm_stream": false}, "stream_0": {"res": "1280x720", "is_record_stream": true, "is_live_stream": true, "is_analytics_stream": false, "codec": "H264", "fps": 10, "is_alarm_stream": true}}, "model": "American Dynamics ADCi610LT-D113"}}', :headers => {})

      stub_request(:get, "http://foo:bar@1.1.1.1/cameras/camera_info/1/?a_random_string").
               with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => '{"cam_info": {"logical_id": "114c05cc-9353-556c-bf27-9c165de62a1c", "associated_text": [], "ip": "10.21.200.101", "arch_mode": 0, "firmware": "AD00-00-17-04", "record_mode": 2, "cameraEnabled": true, "input": 0, "scheduler_enabled": false, "auto_arch_enabled": false, "analytics_mode": 1, "streams_unknown": false, "max_streams": 2, "arch_scheduler_enabled": false, "is_onvif": 0, "stream_options": {"stream_1": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}, "stream_0": {"supported_codecs": ["H264", "MJPEG"], "H264": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 10, "res_default": "1280x720"}, "MJPEG": {"fps_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30], "res_list": ["CIF", "2CIF", "4CIF", "1280x720", "1920x1080"], "fps_default": 7, "res_default": "CIF"}, "default_codec": "H264"}}, "motion_sensitivity": 3, "name": "Parking Lot", "associated_audio": "", "is_firmware_supported": true, "auto_arch_valid": false, "streams": {"stream_1": {"res": "CIF", "is_record_stream": false, "is_live_stream": false, "is_analytics_stream": true, "codec": "MJPEG", "fps": 7, "is_alarm_stream": false}, "stream_0": {"res": "1280x720", "is_record_stream": true, "is_live_stream": true, "is_analytics_stream": false, "codec": "H264", "fps": 10, "is_alarm_stream": true}}, "model": "American Dynamics ADCi610LT-D113"}}', :headers => {})

      result = ve.check_cameras()

      file = File.open(ve.cache_location, "rb")
      file_contents = file.read
      contents = YAML::load(file_contents)
      expect(result.count).to eq(2)

    end

    it 'saves to the cache and then pulls from it' do

      ve = VideoEdgeConnector.new('1.1.1.1','foo','bar')
      ve.cache_location = "./spec/output/cameras2.yml"
      result = ve.check_cameras(true)

      expect(result.count).to eq(4)
      expect(result[0]["ip"]).to eq("10.21.200.100")
      expect(result[3]["ip"]).to eq("10.21.200.103")

    end

  end
end
