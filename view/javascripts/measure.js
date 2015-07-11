function clickAll(allBtn, btnGroup) {
  btnGroup.each(function() {
    if (allBtn.hasClass("active") == $(this).hasClass("active")) {
      $(this).click();
    }
  });
}

function clickMeas(obj, func) {
  src = obj.attr("src");
  targetId = obj.attr("target");
  option = obj.attr("option");
  if ($("#" + targetId).is(':visible')) {
    $("#" + targetId).hide();
  } else {
    $("#" + targetId).show();
    if ($("#" + targetId).attr("data-highcharts-chart") == undefined) {
      func(src, targetId, option);
    }
  }
}

function getMeasuresFloat(measures, attr) {
  var rt = [];
  for (var i = 0; i < measures.length; i++) {
    var v = measures[i][attr];
    if (!$.isEmptyObject(v)) {
      rt.push(parseFloat(v));
    }
  }
  return rt;
}

function getMeasuresStr(measures, attr) {
  var rt = [];
  for (var i = 0; i < measures.length; i++) {
    var v = measures[i][attr];
    if (!$.isEmptyObject(v)) {
      rt.push(v);
    }
  }
  return rt;
}

function doOrderGuaranteedAjax(ajaxOptionArray, allCompleteHandler){

  var defaults = {
    dataType: "text",
    success: function(data) {
      if (ajaxOptionArray[0].func) {
        ajaxOptionArray[0].func(data);
      }
      ajaxOptionArray.shift();
      if (ajaxOptionArray.length == 0 ) {
        if (allCompleteHandler) {
          allCompleteHandler(data);
        }
      } else {
        option = ajaxOptionArray[0];
        opts = $.extend({}, defaults, option.opt);
        $.ajax(opts);
      };
    },
    error: function(req,text,error) {
      alert(error);
    }
  };

  var option = ajaxOptionArray[0];
  var opts = $.extend({}, defaults, option.opt);
  $.ajax(opts);
}

function createChartOfCpu(filePath, targetId) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:     m[0],
        p_usr:    m[1],
        p_nice:   m[2],
        p_sys:    m[3],
        p_iowait: m[4],
        p_irq:    m[5],
        p_soft:   m[6],
        p_steal:  m[7],
        p_guest:  m[8],
        p_idle:   m[9],
      };
      rt.push(o);
    });
    return rt;
  }

  var times;
  var p_usr;
  var p_nice;
  var p_sys;
  var p_iowait;
  var p_irq;
  var p_soft;
  var p_steal;
  var p_guest;
  var p_idle;

  var optionArray = [];
  optionArray.push({opt: {url: filePath}, 
    func: function(data){
      var measures = getArrayMeasures(data);
      times    = getMeasuresStr(measures, 'time');
      p_usr    = getMeasuresFloat(measures, 'p_usr');
      p_nice   = getMeasuresFloat(measures, 'p_nice');
      p_sys    = getMeasuresFloat(measures, 'p_sys');
      p_iowait = getMeasuresFloat(measures, 'p_iowait');
      p_irq    = getMeasuresFloat(measures, 'p_irq');
      p_soft   = getMeasuresFloat(measures, 'p_soft');
      p_steal  = getMeasuresFloat(measures, 'p_steal');
      p_guest  = getMeasuresFloat(measures, 'p_guest');
      p_idle   = getMeasuresFloat(measures, 'p_idle');
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'area'
      },
      title: {
        text: 'CPU'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Percent'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0,
        max: 100,
      },
      tooltip: {
        crosshairs: true,
        shared: true,
        valueSuffix: ' %'
      },
      plotOptions: {
        area: {
          stacking: 'normal',
          lineColor: '#ffffff',
          lineWidth: 1,
          marker: {
            enabled: false,
            lineWidth: 1,
            lineColor: '#ffffff'
          }
        }
      },
      series: [
        { name: '%steal',  data: p_steal },
        { name: '%soft',   data: p_soft },
        { name: '%irq',    data: p_irq },
        { name: '%nice',   data: p_nice },
        { name: '%iowait', data: p_iowait },
        { name: '%usr',    data: p_usr },
        { name: '%sys',    data: p_sys },
      ]
    });
  });
}

function createChartOfMemory(filePath, targetId) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:                    m[0],
        total_memory:            m[1],
        used_memory:             m[2],
        active_memory:           m[3],
        inactive_memory:         m[4],
        free_memory:             m[5],
        buffer_memory:           m[6],
        swap_cache:              m[7],
        total_swap:              m[8],
        used_swap:               m[9],
        free_swap:               m[10],
        non_nice_user_cpu_ticks: m[11],
        nice_user_cpu_ticks:     m[12],
        system_cpu_ticks:        m[13],
        idle_cpu_ticks:          m[14],
        io_wait_cpu_ticks:       m[15],
        irq_cpu_ticks:           m[16],
        softirq_cpu_ticks:       m[17],
        stolen_cpu_ticks:        m[18],
        pages_paged_in:          m[19],
        pages_paged_out:         m[20],
        pages_swapped_in:        m[21],
        pages_swapped_out:       m[22],
        interrupts:              m[23],
        cpu_context_switches:    m[24],
        boot_time:               m[25],
        forks:                   m[26],
      };
      rt.push(o);
    });
    return rt;
  }

  function getUsedMemory(measures) {
    var rt = [];
    for (var i = 0; i < measures.length; i++) {
      var u = measures[i]['used_memory'];
      var b = measures[i]['buffer_memory'];
      var s = measures[i]['swap_cache'];
      if (!$.isEmptyObject(u) && !$.isEmptyObject(b) && !$.isEmptyObject(s)) {
        rt.push(parseFloat(u) - parseFloat(b) - parseFloat(s));
      }
    }
    return rt;
  }

  function getFreeMemory(measures) {
    var rt = [];
    for (var i = 0; i < measures.length; i++) {
      var f = measures[i]['free_memory'];
      var b = measures[i]['buffer_memory'];
      var s = measures[i]['swap_cache'];
      if (!$.isEmptyObject(f) && !$.isEmptyObject(b) && !$.isEmptyObject(s)) {
        rt.push(parseFloat(f) + parseFloat(b) + parseFloat(s));
      }
    }
    return rt;
  }

  var times;
  var free;
  var used;
  var optionArray = [];
  optionArray.push({opt: {url: filePath}, 
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      free  = getFreeMemory(measures);
      used  = getUsedMemory(measures);
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'area'
      },
      title: {
        text: 'MEMORY'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Byte'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0,
      },
      tooltip: {
        crosshairs: true,
        shared: true,
        valueSuffix: ' Byte'
      },
      plotOptions: {
        area: {
          stacking: 'normal',
          lineColor: '#ffffff',
          lineWidth: 1,
          marker: {
            enabled: false,
            lineWidth: 1,
            lineColor: '#ffffff'
          }
        }
      },
      series: [
        { name: 'free',   data: free },
        { name: 'used',   data: used },
      ]
    });
  });
}

function createChartOfLoadavg(filePath, targetId) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:     m[0],
        avg1:     m[1],
        avg5:     m[2],
        avg15:    m[3],
      };
      rt.push(o);
    });
    return rt;
  }

  var times;
  var avg1;
  var avg5;
  var avg15;
  var optionArray = [];
  optionArray.push({opt: {url: filePath}, 
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      avg1  = getMeasuresFloat(measures, 'avg1');
      avg5  = getMeasuresFloat(measures, 'avg5');
      avg15 = getMeasuresFloat(measures, 'avg15');
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Load Average'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Job / Run queue'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true,
        valueSuffix: ' Job'
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: [
        { name: '1min',  marker: { symbol: 'diamond' }, data: avg1 },
        { name: '5min',  marker: { symbol: 'diamond' }, data: avg5 },
        { name: '15min', marker: { symbol: 'diamond' }, data: avg15 },
      ]
    });
  });
}

function createChartOfNetwork(filePath, targetId, interval) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:     m[0],
        rx_ok:    m[1],
        rx_error: m[2],
        rx_drp:   m[3],
        rx_ovr:   m[4],
        tx_ok:    m[5],
        tx_error: m[6],
        tx_drp:   m[7],
        tx_ovr:   m[8],
      };
      rt.push(o);
    });
    return rt;
  }

  function getMeasuresDiffVal(measures, attr) {
    var rt = [];
  for (var i = 0; i < measures.length; i++) {
      if (i == 0) {
        rt.push(0);
        continue;
      }
      var s = measures[i - 1][attr];
      var e = measures[i][attr];
      if (!$.isEmptyObject(s) && !$.isEmptyObject(e)) {
        rt.push((parseFloat(e) - parseFloat(s)) / interval);
      }
    }
    return rt;
  }

  var times;
  var rx_ok;
  var tx_ok;
  var optionArray = [];
  optionArray.push({opt: {url: filePath}, 
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      rx_ok  = getMeasuresDiffVal(measures, 'rx_ok');
      tx_ok  = getMeasuresDiffVal(measures, 'tx_ok');
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Network'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Packet'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true,
        valueSuffix: ' Packet'
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: [
        { name: 'rx_ok', data: rx_ok },
        { name: 'tx_ok', data: tx_ok },
      ]
    });
  });
}

function createChartOfDiskIO(filePath, targetId) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:     m[0],
        rrqm_s:   m[1],
        wrpm_s:   m[2],
        r_s:      m[3],
        w_s:      m[4],
        rkb_s:    m[5],
        wkb_s:    m[6],
        avgrq_sz: m[7],
        avgqu_sz: m[8],
        await:    m[9],
        svctm:    m[10],
        p_util:   m[11],
      };
      rt.push(o);
    });
    return rt;
  }

  var times;
  var rkb_s;
  var wkb_s;
  var optionArray = [];
  optionArray.push({opt: {url: filePath}, 
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      rkb_s = getMeasuresFloat(measures, 'rkb_s');
      wkb_s = getMeasuresFloat(measures, 'wkb_s');
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Disk-IO'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'KByte'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true,
        valueSuffix: ' KByte'
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: [
        { name: 'rkB/s', data: rkb_s },
        { name: 'wkB/s', data: wkb_s },
      ]
    });
  });
}

function createChartOfDiskUsage(filePath, targetId) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:      m[0],
        k_blocks:  m[1],
        used:      m[2],
        available: m[3],
        p_use:     m[4],
      };
      rt.push(o);
    });
    return rt;
  }

  var times;
  var used;
  var optionArray = [];
  optionArray.push({opt: {url: filePath}, 
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      used  = getMeasuresFloat(measures, 'used');
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Disk-Usage'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Byte'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true,
        valueSuffix: ' Byte'
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: [
        { name: 'used', data: used },
      ]
    });
  });
}

function createChartOfDiskUtil(filePath, targetId) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:     m[0],
        rrqm_s:   m[1],
        wrpm_s:   m[2],
        r_s:      m[3],
        w_s:      m[4],
        rkb_s:    m[5],
        wkb_s:    m[6],
        avgrq_sz: m[7],
        avgqu_sz: m[8],
        await:    m[9],
        svctm:    m[10],
        p_util:   m[11],
      };
      rt.push(o);
    });
    return rt;
  }

  var times;
  var rkb_s;
  var wkb_s;
  var optionArray = [];
  optionArray.push({opt: {url: filePath}, 
    func: function(data){
      var measures = getArrayMeasures(data);
      times  = getMeasuresStr(measures, 'time');
      p_util = getMeasuresFloat(measures, 'p_util');
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Disk-Util'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Percent'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0,
        max: 100
      },
      tooltip: {
        crosshairs: true,
        shared: true,
        valueSuffix: ' %'
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: [
        { name: '%util', data: p_util },
      ]
    });
  });
}

function createChartOfLineCount(filePath, targetId, opt) {

  var fileName = opt.split(":")[0];
  var conditions = opt.split(":")[1].split("#");

  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = new Object();
      o["time"] = m[0];
      $.each(conditions, function(index, elem) {
        o[elem] = m[index + 1];
      });
      rt.push(o);
    });
    return rt;
  }

  var times;
  var values = new Object;
  var optionArray = [];
  optionArray.push({opt: {url: filePath},
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      $.each(conditions, function(index, elem) {
        values[elem] = getMeasuresFloat(measures, elem);
      });
  }});

  doOrderGuaranteedAjax(optionArray, function(data){

    var series = new Array();
    $.each(conditions, function(index, elem) {
      series.push({ name: elem, marker: { symbol: 'diamond' }, data: values[elem] })
    });

    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: fileName
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Count'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: series
    });
  });
}

function createChartOfPsCount(filePath, targetId, opt) {

  var conditions = opt.split("#");

  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = new Object();
      o["time"] = m[0];
      $.each(conditions, function(index, elem) {
        o[elem] = m[index + 1];
      });
      rt.push(o);
    });
    return rt;
  }

  var times;
  var values = new Object;
  var optionArray = [];
  optionArray.push({opt: {url: filePath},
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      $.each(conditions, function(index, elem) {
        values[elem] = getMeasuresFloat(measures, elem);
      });
  }});

  doOrderGuaranteedAjax(optionArray, function(data){

    var series = new Array();
    $.each(conditions, function(index, elem) {
      series.push({ name: elem, marker: { symbol: 'diamond' }, data: values[elem] })
    });

    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Process Count'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Count'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: series
    });
  });
}

function createChartOfPsAggregate(filePath, targetId, opt) {

  var conditions = opt.split("#");

  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = new Object();
      o["time"] = m[0];
      $.each(conditions, function(index, elem) {
        o[elem] = m[index + 1];
      });
      rt.push(o);
    });
    return rt;
  }

  var times;
  var values = new Object;
  var optionArray = [];
  optionArray.push({opt: {url: filePath},
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      $.each(conditions, function(index, elem) {
        values[elem] = getMeasuresFloat(measures, elem);
      });
  }});

  doOrderGuaranteedAjax(optionArray, function(data){

    var series = new Array();
    $.each(conditions, function(index, elem) {
      series.push({ name: elem, marker: { symbol: 'diamond' }, data: values[elem] })
    });

    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Process Aggregate'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Value'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: series
    });
  });
}

function createChartOfFdCount(filePath, targetId, opt) {

  var conditions = opt.split("#");

  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = new Object();
      o["time"] = m[0];
      $.each(conditions, function(index, elem) {
        o[elem] = m[index + 1];
      });
      rt.push(o);
    });
    return rt;
  }

  var times;
  var values = new Object;
  var optionArray = [];
  optionArray.push({opt: {url: filePath},
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      $.each(conditions, function(index, elem) {
        values[elem] = getMeasuresFloat(measures, elem);
      });
  }});

  doOrderGuaranteedAjax(optionArray, function(data){

    var series = new Array();
    $.each(conditions, function(index, elem) {
      series.push({ name: elem, marker: { symbol: 'diamond' }, data: values[elem] })
    });

    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'File Descriptor Count'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'Count'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: series
    });
  });
}

function createChartOfIops(filePath, targetId) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:     m[0],
        rrqm_s:   m[1],
        wrpm_s:   m[2],
        r_s:      m[3],
        w_s:      m[4],
        rkb_s:    m[5],
        wkb_s:    m[6],
        avgrq_sz: m[7],
        avgqu_sz: m[8],
        await:    m[9],
        svctm:    m[10],
        p_util:   m[11],
      };
      rt.push(o);
    });
    return rt;
  }

  var times;
  var r_s;
  var w_s;
  var optionArray = [];
  optionArray.push({opt: {url: filePath},
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      r_s = getMeasuresFloat(measures, 'r_s');
      w_s = getMeasuresFloat(measures, 'w_s');
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'column'
      },
      title: {
        text: 'IOPS'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'IOPS'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true,
        valueSuffix: ' IOPS'
      },
      plotOptions: {
        column: {
          stacking: 'normal',
          dataLabels: {
            enabled: false,
          }
        }
      },
      series: [
        { name: 'r/s', data: r_s },
        { name: 'w/s', data: w_s },
      ]
    });
  });
}

function createChartOfDiskInode(filePath, targetId) {
  function getArrayMeasures(data) {
    var rt = [];
    $.each(data.split('\n'), function() {
      var m = this.split(',');
      var o = {
        time:      m[0],
        nodes:     m[1],
        used:      m[2],
        free:      m[3],
        p_use:     m[4],
      };
      rt.push(o);
    });
    return rt;
  }

  var times;
  var used;
  var optionArray = [];
  optionArray.push({opt: {url: filePath},
    func: function(data){
      var measures = getArrayMeasures(data);
      times = getMeasuresStr(measures, 'time');
      used  = getMeasuresFloat(measures, 'used');
  }});

  doOrderGuaranteedAjax(optionArray, function(data){
    $("#" + targetId).highcharts({
      chart: {
        type: 'spline'
      },
      title: {
        text: 'inode'
      },
      subtitle: {
        text: filePath
      },
      xAxis: {
        title: {
          text: 'Time'
        },
        categories: times,
        tickInterval: parseInt(times.length / 10)
      },
      yAxis: {
        title: {
          text: 'inode'
        },
        labels: {
          formatter: function() {
            return this.value
          }
        },
        min: 0
      },
      tooltip: {
        crosshairs: true,
        shared: true,
      },
      plotOptions: {
        spline: {
          marker: {
            enabled: false,
            radius: 4,
            lineColor: '#666666',
            lineWidth: 1
          }
        }
      },
      series: [
        { name: 'IUsed', data: used },
      ]
    });
  });
}
