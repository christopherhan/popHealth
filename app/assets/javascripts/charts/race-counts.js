$(document).ready(function() {
    var chart;
	chart = new Highcharts.Chart({
	chart: {
		renderTo: 'race-counts',
		defaultSeriesType: 'bar'
	},
	title: {
		text: 'Patients by Race'
	},
	xAxis: {
		categories: ['American Indian or Alaskan Native', 'Asian', 'Black or African American', 'Native Hawaiian Or Other Pacific Islander', 'White', 'Other Race'],
		title: {
			text: null
		}
	},
	yAxis: {
		min: 0,
		title: {
			text: 'Number of Patients',
			align: 'high'
		}
	},
	tooltip: {
		formatter: function() {
			return ''+
				 this.series.name +': '+ this.y +' millions';
		}
	},
	plotOptions: {
		bar: {
			dataLabels: {
				enabled: true
			}
		}
	},
	legend: {
		layout: 'vertical',
		align: 'right',
		verticalAlign: 'top',
		x: -100,
		y: 100,
		floating: true,
		borderWidth: 1,
		backgroundColor: '#FFFFFF',
		shadow: true
	},
	credits: {
		enabled: false
	},
        series: [{
		name: 'Patients',
		data: [107, 31, 191, 203, 100,100]
	}]
});

});