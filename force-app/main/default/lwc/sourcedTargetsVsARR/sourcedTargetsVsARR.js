import { LightningElement } from 'lwc';
import getData from '@salesforce/apex/Ctrl_DashboardPageApp.getTargets';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import chartJS from '@salesforce/resourceUrl/chartJS360';

export default class TargetsVsARR extends LightningElement {
    jQueryInitialized = false;
    chartInitialized = false;
    chartsDrawn = false;
    dataLoaded = false;
    tiles;
    mTile;
    qTile;
    yTile;

    connectedCallback(){
        console.log('Sourced TargetsVsARR Connected');
        window._stemplate = this.template;
        this.init();
    }

    renderedCallback(){
        console.log('Sourced TargetsVsARR Rendered');

        if (this.chartInitialized) {
            return;
        }
        this.chartInitialized = true;

        Promise.all([
            loadScript(this, chartJS + '/chart.min.js')
        ]).then(() => {
            console.log('chartJS loaded');
            if (this.dataLoaded && !this.chartsDrawn){
                console.log('Init charts after chart loaded @ sourced');
                this.initDonuts();
            }
        }).catch(error => {
            this.chartInitialized = false;
            console.error('Error loading chartJS @ sourced: ' + error);
        });
    }

    init(){
        getData({ source : 'sourced' })
        .then((data) => {
            if (!this.isEmpty(data)){
                this.tiles = new Array();
                let tile = {};
                tile.index = 0;
                tile.titleText = 'Your monthly target ARR:';
                tile.titleValue = '$' + data.m_target;
                tile.innerTitleText = 'Monthly ARR';
                tile.innerTitleValue = '$' + data.m_total;
                tile.inboundARR = '$' + data.m_inbound;
                tile.outboundARR = '$' + data.m_outbound;
                tile.data = new Array();
                tile.data.push(data.m_inbound);
                tile.data.push(data.m_outbound);
                tile.data.push(data.m_target - (data.m_inbound + data.m_outbound));
                this.tiles.push(JSON.parse(JSON.stringify(tile)));
                tile = {};
                tile.index = 1;
                tile.titleText = 'Your quarterly target ARR:';
                tile.titleValue = '$' + data.q_target;
                tile.innerTitleText = 'Quarterly ARR';
                tile.innerTitleValue = '$' + data.q_total;
                tile.inboundARR = '$' + data.q_inbound;
                tile.outboundARR = '$' + data.q_outbound;
                tile.data = new Array();
                tile.data.push(data.q_inbound);
                tile.data.push(data.q_outbound);
                tile.data.push(data.q_target - (data.q_inbound + data.q_outbound));
                this.tiles.push(JSON.parse(JSON.stringify(tile)));
                tile = {};
                tile.index = 2;
                tile.titleText = 'Your yearly target ARR:';
                tile.titleValue = '$' + data.y_target;
                tile.innerTitleText = 'Yearly ARR';
                tile.innerTitleValue = '$' + data.y_total;
                tile.inboundARR = '$' + data.y_inbound;
                tile.outboundARR = '$' + data.y_outbound;
                tile.data = new Array();
                tile.data.push(data.y_inbound);
                tile.data.push(data.y_outbound);
                tile.data.push(data.y_target - (data.y_inbound + data.y_outbound));
                this.tiles.push(JSON.parse(JSON.stringify(tile)));
                this.mTile = this.tiles[0];
                this.qTile = this.tiles[1];
                this.yTile = this.tiles[2];

                window._sourceTilesArr = this.tiles;

                this.dataLoaded = true;
                console.log('Data loaded');
                
                if (this.chartInitialized && !this.chartsDrawn){
                    console.log('Init charts after data loaded');
                    setTimeout(this.initDonuts, 1500);
                }
            }
        })
        .catch((err) => { console.log('Error loading targets data: ' + err); console.log('Error loading targets data: ' + JSON.stringify(err)); });
    }

    initDonuts(){
        console.log('Initializing Charts @ sourced');
        var ctx = new Array(3);
        var myChart = null;
        try{
            for (let i = 0; i < window._sourceTilesArr.length; i++){
                ctx[i] = window._stemplate.querySelector('canvas.myChart' + i).getContext('2d');
                console.log('window._sourceTilesArr[i].data: ' + JSON.stringify(window._sourceTilesArr[i].data));
                myChart = new Chart(ctx[i], {
                    type: 'doughnut',
                    data: {
                        labels: ['Inbound', 'Outbound', 'Gap to Target'],
                        datasets: [{
                            label: 'Targets Vs. ARR',
                            data: window._sourceTilesArr[i].data,
                            backgroundColor: [
                                'rgba(91, 94, 209, 1)',
                                'rgba(15, 216, 244, 1)',
                                'rgba(244, 244, 244, 1)'
                            ]
                        }]
                    },
                    options: {
                        cutout: '70%',
                        responsive: false,
                        plugins: {
                            legend: {
                                display: false
                            }
                        }
                    }
                });
            }
        }catch(err){
            console.log('Error initializing charts: ' + err);
        }
        
        //this.chartsDrawn = true;
    }

    /**
    * @param {Object} obj Any object to test
    * @return {Boolean} true if empty
    */
     isEmpty(obj){
        return (obj == null || obj == 'null' || typeof(obj) == 'undefined' || obj == 'undefined' || obj == '');
    }
}