/** JW Player plugin that pings playback events back to server. **/
window.jwplayer().registerPlugin('ping', '6.12', function(_player, _options, _div) {

    /** No display elements, but function is required. **/
    _div.style.display = 'none';
    this.resize = function() {};

    /** Interval for sending progress events. **/
    var _interval = 30;
    /** Last time tick **/
    var _lastTime = -1;
    /** Page referrer. **/
    var _referrer = '';
    /** Start time **/
    var _startTime = -1;

    /** Initialize the plugin on player ready. **/
    _player.onReady(function() {
        _player.onBuffer(_stateHandler);
        _player.onPlay(_stateHandler);
        _player.onIdle(_idleHandler);
        _player.onTime(_timeHandler);
        if(window.top !== window) {
            _referrer = document.referrer;
        } else {
            _referrer = window.location.href;
        }
        _sendPing('ready');
    });

    /** If moving from idle, the item is started. **/
    function _stateHandler(event) {
        if(event.oldstate === window.jwplayer.events.state.IDLE) {
            _sendPing('item');
            _startTime = -1;
            _lastTime = -1;
        }
    }

    /** Only send idle pings if the player indeed stopped. **/
    function _idleHandler() {
        if(_startTime > -1) {
            _sendPing('stop');
        }
    }

    /** Send the last playback after a seek. **/
    function _timeHandler(event) {
        if (_startTime === -1) {
            _startTime = _lastTime = event.position;
        } else if (Math.abs(event.position - _lastTime) > 1) {
            if(_lastTime - _startTime > 2) {
                _sendPing('seek');
            }
            _startTime = -1;
            _lastTime = -1;
        } else if(_lastTime - _startTime > _interval) {
            _sendPing('progress');
            _startTime = _lastTime = event.position;
        } else {
            _lastTime = event.position;
        }
    }

    /** Wrap up the url generation and do the ping. **/
    function _sendPing(event) {
        var query = '?event='+event;
        var item = _player.getPlaylistItem();
        var mediaid = item.mediaid;
        if(!mediaid) {
        	console.log('No media_id found');
        	return;
        }
        var file = item.file;
        if(!file) {
            file = item.sources[0].file;
        }
        switch(event) {
            case 'item':
                query += '&file='+encodeURIComponent(file);
                query += '&mediaid='+encodeURIComponent(mediaid);
                break;
            case 'ready':
                query += '&referrer=' + encodeURIComponent(_referrer);
                query += '&playerid='+encodeURIComponent(_player.id);
                break;
            case 'progress':
            case 'seek':
            case 'stop':
                query += '&file='+encodeURIComponent(file);
                query += '&mediaid='+encodeURIComponent(mediaid);
                query += '&start=' + Math.round(_startTime*10)/10;
                query += '&duration=' + Math.round((_lastTime-_startTime)*10)/10;
                break;
        }
        query += '&r='+Math.random();
        if(_options.pixel) {
            var image = new Image();
            image.src = _options.pixel + query;
        } else {
            try {
                console.log(query);
            } catch(error) {}
        }
    }
});
