({
	init : function(component, event, helper) {
        var action = component.get("c.getDetails");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
            var chartLabels = [];
            var chartData = [];
            var detailString = data.getReturnValue();
            var detailObj = JSON.parse( detailString );
            for (var key in detailObj) {
                chartLabels.push(key);
                chartData.push(detailObj[key]);
            }

            var myCharts = component.find("myChartsChangedBy").getElement();
            
          
            Chart.defaults.global.defaultFontFamily = 'Arial,sans-serif';
            Chart.defaults.global.defaultFontSize = 18;
            Chart.defaults.global.defaultFontColor = '#777';

            var popCharts = new Chart(myCharts,{
                type : 'pie',
                data : {
                    labels : chartLabels,
                    datasets : [{
                        label : 'User',
                        data : chartData,
                        backgroundColor : [
                            'rgba(255, 99, 132, 0.6)',
                            'rgba(54, 162, 235, 0.6)',
                            'rgba(255, 206, 86, 0.6)',
                            'rgba(75, 192, 192, 0.6)',
                            'rgba(153, 102, 255, 0.6)',
                            'rgba(255, 159, 64, 0.6)',
                            'rgba(255, 99, 132, 0.6)'
                        ],
                        borderWidth : 2,
                        borderColor : '#777',
                        hoverBorderWidth : 3,
                        hoverBorderColor :'#000'
                    }],
                },
                options : {
                    title : {
                        display : true,
                        text : 'Components Changed By User',          
                        fontSize : 20
                    },
                    legend : {
                        position : 'bottom',
                        labels : {
                            fontColor : '#000'
                        }
                    }
                }
            });
		});
        $A.enqueueAction(action);
    }
})