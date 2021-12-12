import { LightningElement } from 'lwc';
import tierBadges from '@salesforce/resourceUrl/DashboardTierStatus';
import getMapp from '@salesforce/apex/Ctrl_DashboardPageApp.getMapp';

export default class Mapp extends LightningElement {
    mapsLabel = '';
    mapsPositionStyle = '';


    connectedCallback(){
        getMapp()
        .then((data) => {
            console.log('MAPP data: ' + JSON.stringify(data));
            if (!this.isEmpty(data) && !this.isEmpty(data.mapp)){
                this.mapsLabel = data.mapp + '%';
                if (data.mapp < 8){
                    this.mapsPositionStyle = 'left: ' + data.mapp + '%;';
                    this.mapsPositionStyle += 'background-image: url(' +  tierBadges + '/RightHalfArrowMarker.png);';
                    this.mapsPositionStyle += 'background-position-x: left;'
                } else if (data.mapp > 84) {
                    this.mapsPositionStyle = 'right: calc(-' + data.mapp + '% + 52px);';
                    this.mapsPositionStyle += 'background-image: url(' + tierBadges + '/LeftHalfArrowMarker.png);';
                    this.mapsPositionStyle += 'background-position-x: right;'
                } else {
                    this.mapsPositionStyle = 'left: calc(' + data.mapp + '% - 26px);';
                }
            }
        })
        .catch((err) => { console.log('Error loading MAPP: ' + JSON.stringify(err)); });
    }

    /**
    * @param {Object} obj Any object to test
    * @return {Boolean} true if empty
    */
     isEmpty(obj){
        return ((obj == null || obj == 'null' || typeof(obj) == 'undefined' || obj == 'undefined' || obj == '') && obj != 0);
    }
}