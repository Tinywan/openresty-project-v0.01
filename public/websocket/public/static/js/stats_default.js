var descriptions = {
    'Processes': {
        'title' : '进程',
        'items' : {
            'r': '运行进程数',
            'b': '阻塞进程数'
        },
        'unit':'个'
    },
    'Memory': {
        'title' : '内存',
        'items' : {
            'swpd': '已使用虚拟内存',
            'free': '空闲物理内存',
            'buff': '已使用缓存',
            'cache': '缓存大小'
        },
        'unit':'B'
    },
    'Swap': {
        'title':'交换内存',
        'items':{
            'si': '从磁盘中读入的虚拟内存',
            'so': '从虚拟内存中写入磁盘大小'
        },
        'unit':'B'
    },
    'IO': {
        'title':'IO开销',
        'items':{
            'bi': '从块设备接收的块大小',
            'bo': '从块设备改善的块大小'
        },
        'unit':'个'
    },
    'System': {
        'title':'系统',
        'items':{
            'ir': '每秒中断次数',
            'cs': '上下文切换次数'
        },
        'unit':'次'
    },
    'CPU': {
        'title':'CPU',
        'items':{
            'us': '用户CPU时间',
            'sy': '系统CPU时间',
            'id': '空闲CPU时间',
            'wa': '等待IO CPU时间'
        },
        'unit':'秒'
    }
}

var num = 0;
function streamStats() {
    var ws = new ReconnectingWebSocket('ws://' + location.host + '/lua_websocket_server');
    ws.onopen = function() {
        console.log('connect');
        ws.send('hello');
    };

    ws.onclose = function() {
        console.log('disconnect');
    };

    ws.onmessage = function(e) {
        // receiveStats(JSON.parse(e.data));
        console.log(e.data);
    };
}

function initCharts() {
    for(var opt in descriptions) {
        var dataList = [];
        for (var v in descriptions[opt].items) {
            dataList.push({
                name: descriptions[opt]['items'][v],
                data: [
                    [(new Date()).getTime(),0]
                ]
            });
        }
        Highcharts.setOptions({
            global: {
                useUTC: false
            }
        });

        $('#'+opt+'-canvas').highcharts({
            chart: {
                type: 'spline',
                animation: Highcharts.svg,
                marginRight: 10
            },
            title: {
                text: descriptions[opt].title
            },
            credits : {
                enabled:false
            },
            xAxis: {
                maxPadding : 0.05,
                minPadding : 0.05,
                type: 'datetime',
                tickWidth:5
            },
            yAxis: {
                title: {
                    text: descriptions[opt].unit
                },
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }]
            },
            tooltip: {
                formatter: function() {
                    return '<b>'+ this.series.name +'</b>('+num+')<br/>'+
                        Highcharts.dateFormat('%H:%M:%S', this.x) +'<br/>'+
                        Highcharts.numberFormat(this.y, 2);
                }
            },
            legend: {
                enabled: true
            },
            exporting: {
                enabled: false
            },
            series: dataList
        });
    }
}

function receiveStats(stats) {
    console.log(stats);
    //var time = (new Date()).getTime();
    var time = stats.time*1000;
    for(var opt in descriptions) {
        var chart = $('#'+opt+'-canvas').highcharts();
        var i = 0;
        for (var v in descriptions[opt].items) {
            chart.series[i].addPoint([time, parseInt(stats[v])], true, (num>120?true:false));
            i++;
        }

    }
    num++;
}

$(function() {
    initCharts();
    streamStats();
});