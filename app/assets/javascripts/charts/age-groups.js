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
		categories: ['0-10', '11-18', '19-25', '26-35', '36-45','46-55', '56-65', '66-75', '76+'],
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
        data: [ '0-10' in age_groups ? age_groups['0-10'] : 0,
                '11-18' in age_groups ? age_groups['11-18'] : 0, 
                '19-25' in age_groups ? age_groups['19-25'] : 0, 
                '26-35' in age_groups ? age_groups['26-35'] : 0, 
                '36-45' in age_groups ? age_groups['36-45'] : 0, 
                '46-55' in age_groups ? age_groups['46-55'] : 0,
                '56-65' in age_groups ? age_groups['56-65'] : 0,
                '66-75' in age_groups ? age_groups['66-75'] : 0,
                '76+' in age_groups ? age_groups['76+'] : 0]
	}]
});

});
