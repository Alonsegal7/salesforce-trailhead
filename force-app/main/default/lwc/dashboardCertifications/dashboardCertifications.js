import { LightningElement } from 'lwc';
import badges from '@salesforce/resourceUrl/DashboardCertifications';
import loadCertifications from '@salesforce/apex/Ctrl_DashboardPageApp.getCertifications';
import certReportURL from '@salesforce/label/c.Dashboard_CertificationReport';

export default class DashboardCertifications extends LightningElement {
    salesBadge;
    amBadge;
    csmBadge;
    salesCertCount;
    salesCertOutOf;
    csmCertCount;
    csmCertOutOf;
    amCertCount;
    amCertOutOf;

    connectedCallback(){
        this.salesBadge = badges + '/sales_badge.png';
        this.amBadge = badges + '/am_badge.png';
        this.csmBadge = badges + '/csm_badge.png';
        this.init();
    }

    handleClick(){
        window.location.href = certReportURL;
    }

    init(){
        loadCertifications()
        .then((data) => {
            console.log('Certifications data: ' + JSON.stringify(data));
            this.salesCertCount = data.sales;
            this.salesCertOutOf = data.sales_out_of;
            this.csmCertCount = data.csm;
            this.csmCertOutOf = data.csm_out_of;
            this.amCertCount = data.am;
            this.amCertOutOf = data.am_out_of;
        })
        .catch((err) => { console.log('Error loading certifications: ' + err); });
    }
}