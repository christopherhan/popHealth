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
		categories: ['American Indian or Alaskan Native', 
                     'Asian', 
                     'Black or African American', 
                     'Native Hawaiian Or Other Pacific Islander', 
                     'White', 
                     'Other Race'],
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
				 this.series.name +': '+ this.y;
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
		x: -20,
		y: 50,
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
		data: [ 'American Indian Or Alaska Native' in race_counts ? race_counts['American Indian Or Alaska Native'] : 0,
                'Asian' in race_counts ? race_counts['Asian'] : 0,
                'Black Or African American' in race_counts ? race_counts['Black Or African American'] : 0,
                'Native Hawaiian Or Other Pacific Islander' in race_counts ? race_counts['Native Hawaiian Or Other Pacific Islander'] : 0,
                'White' in race_counts ? race_counts['White'] : 0,
                'Other Race' in race_counts ? race_counts['Other Race'] : 0
            ]
	}]
});

});
