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
    	//categories: ['<18', '18-25', '25-35', '36-45', '46-55', '56-65', '66+']
        categories: ['0-10', '11-18', '19-25', '26-35', '36-45','46-55', '56-65', '66-75', '76+'],
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
    	data: [ '0-10' in age_males ? age_males['0-10'] : 0, 
                '11-18' in age_males ? age_males['11-18'] : 0,
                '19-25' in age_males ? age_males['19-25'] : 0,
                '26-35' in age_males ? age_males['26-35'] : 0,
                '36-45' in age_males ? age_males['36-45'] : 0,
                '46-55' in age_males ? age_males['46-55'] : 0,
                '56-65' in age_males ? age_males['56-65'] : 0,
                '66-75' in age_males ? age_males['66-75'] : 0,
                '76+' in age_males ? age_males['76+'] : 0]
    }, {
    	type: 'column',
    	name: 'Female',
    	data: [ '0-10' in age_females ? age_females['0-10'] : 0, 
                '11-18' in age_females ? age_females['11-18'] : 0,
                '19-25' in age_females ? age_females['19-25'] : 0,
                '26-35' in age_females ? age_females['26-35'] : 0,
                '36-45' in age_females ? age_females['36-45'] : 0,
                '46-55' in age_females ? age_females['46-55'] : 0,
                '56-65' in age_females ? age_females['56-65'] : 0,
                '66-75' in age_females ? age_females['66-75'] : 0,
                '76+' in age_females ? age_females['76+'] : 0]

    }, {
    	type: 'pie',
    	name: 'Gender breakdown',
    	data: [{
    		name: 'Male',
    		y: num_males,
    		color: '#4572A7' // Jane's color
    	}, {
    		name: 'Female',
    		y: num_females,
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
