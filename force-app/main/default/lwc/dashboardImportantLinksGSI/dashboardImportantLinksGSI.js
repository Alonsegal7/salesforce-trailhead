import { LightningElement } from 'lwc';
import icons from '@salesforce/resourceUrl/DashboardImportantLinks';
import dashboardURL from '@salesforce/label/c.Dashboard_BoardLink';
import partnerCommunityURL from '@salesforce/label/c.Dashboard_PartnerCommunityLink';
import knowladgeBaseURL from '@salesforce/label/c.Dashboard_KBLink';
import assetURL from '@salesforce/label/c.Dashboard_AssetLink';
import partnerAcademyURL from '@salesforce/label/c.Dashboard_Lessonly_Link';
import opportunityRegistrationURL from '@salesforce/label/c.Dashboard_Opportunity_Registration';

export default class DashboardImportantLinksGSI extends LightningElement {
    linksLoaded = false;
    links;

    connectedCallback(){
        this.init();
    }

    init(){
        this.links = new Array();
        let item = {};
        item.name = 'Partner Community';
        item.title = 'Partners Community';
        item.url = partnerCommunityURL;
        item.src = icons + '/PartnerCommunity.png';
        this.links.push(JSON.parse(JSON.stringify(item)));

        item = {};
        item.name = 'Knowledge Base';
        item.title = 'Knowledge Base';
        item.url = knowladgeBaseURL;
        item.src = icons + '/KnowledgeBase.png';
        this.links.push(JSON.parse(JSON.stringify(item)));

        item = {};
        item.name = 'Partner Academy on Lessonly';
        item.title = 'Partner Academy on Lessonly';
        item.url = partnerAcademyURL;
        item.src = icons + '/Lessonly.png';
        this.links.push(JSON.parse(JSON.stringify(item)));        
        
        /*
        item = {};
        item.name = 'PCSM Board';
        item.title = 'PCSM Board';
        item.url = dashboardURL;
        item.src = icons + '/BoardwithCPM.png';
        this.links.push(JSON.parse(JSON.stringify(item)));
        */
        item = {};
        item.name = 'Branding Assets';
        item.title = 'Co-branding assets on figma';
        item.url = assetURL;
        item.src = icons + '/BrandingAssets.png';
        this.links.push(JSON.parse(JSON.stringify(item)));

        item = {};
        item.name = 'Opportunity Registration';
        item.title = 'Opportunity Registration';
        item.url = opportunityRegistrationURL;
        item.src = icons + '/BoardwithCPM.png';
        this.links.push(JSON.parse(JSON.stringify(item)));

        this.linksLoaded = true;
    }
}