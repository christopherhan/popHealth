$(document).ready(function() {
    var chart;
	chart = new Highcharts.Chart({
	chart: {
		renderTo: 'age-groups',
		defaultSeriesType: 'bar'
	},
	title: {
		text: 'Age Groups'
	},
	xAxis: {
		categories: ['0-10', '11-18', '19-25', '26-35', '36-45','46-55', '56-65', '66-75"', '76+'],
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
		data: [10, 54, 68, 98, 103, 115, 87, 54, 33]
	}]
});

});