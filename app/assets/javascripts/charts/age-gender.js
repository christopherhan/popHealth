$(document).ready(function() {
    var age_gender_chart;
	age_gender_chart = new Highcharts.Chart({
	chart: {
    	renderTo: 'age-gender'
    },
    title: {
    	text: 'Gender-Age Breakdown'
    },
    xAxis: {
    	categories: ['<18', '18-25', '25-35', '36-45', '46-55', '56-65', '66+']
    },
    tooltip: {
    	formatter: function() {
    		var s;
    		if (this.point.name) { // the pie chart
    			s = ''+
    				this.point.name +': '+ this.y +' ';
    		} else {
    			s = ''+
    				this.x  +': '+ this.y;
    		}
    		return s;
    	}
    },
    labels: {
    	items: [{
    		html: 'Gender Breakdown',
    		style: {
    			left: '40px',
    			top: '8px',
    			color: 'black'				
    		}
    	}]
    },
    series: [{
    	type: 'column',
    	name: 'Male',
    	data: [3, 2, 1, 3, 4, 5, 2]
    }, {
    	type: 'column',
    	name: 'Female',
    	data: [2, 3, 5, 7, 6, 2, 4]
    }, {
    	type: 'pie',
    	name: 'Gender breakdown',
    	data: [{
    		name: 'Male',
    		y: window.num_females,
    		color: '#4572A7' // Jane's color
    	}, {
    		name: 'Female',
    		y: window.num_males,
    		color: '#AA4643' // John's color	
    	}],
    	center: [100, 80],
    	size: 100,
    	showInLegend: false,
    	dataLabels: {
    		enabled: false
    	}
    }]
    });
});