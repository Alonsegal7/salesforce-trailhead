import { LightningElement } from 'lwc';
import icons from '@salesforce/resourceUrl/DashboardImportantLinks';
import dashboardURL from '@salesforce/label/c.Dashboard_BoardLink';
import partnerCommunityURL from '@salesforce/label/c.Dashboard_PartnerCommunityLink';
import knowladgeBaseURL from '@salesforce/label/c.Dashboard_KBLink';
import assetURL from '@salesforce/label/c.Dashboard_AssetLink';
import partnerAcademyURL from '@salesforce/label/c.Dashboard_Lessonly_Link';

export default class DashboardImportantLinks extends LightningElement {
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
        item.hoverTitle = 'Knowledge Base';
        item.url = knowladgeBaseURL;
        item.src = icons + '/KnowledgeBase.png';
        this.links.push(JSON.parse(JSON.stringify(item)));

        item = {};
        item.name = 'Partner Academy on Lessonly';
        item.title = 'Partner Academy on Lessonly';
        item.hoverTitle = 'Partner Academy on Lessonly';
        item.url = partnerAcademyURL;
        item.src = icons + '/Lessonly.png';
        this.links.push(JSON.parse(JSON.stringify(item)));        
        
        item = {};
        item.name = 'PCSM Strategic Accounts';
        item.title = 'PCSM Strategic Accounts';
        item.hoverTitle = 'This board is available only for PCSMs, relevant partners will have acsess to this board';
        item.url = dashboardURL;
        item.src = icons + '/BoardwithCPM.png';
        this.links.push(JSON.parse(JSON.stringify(item)));

        item = {};
        item.name = 'Branding Assets';
        item.title = 'Co-branding assets on figma';
        item.hoverTitle = 'Co-branding assets on figma';
        item.url = assetURL;
        item.src = icons + '/BrandingAssets.png';
        this.links.push(JSON.parse(JSON.stringify(item)));        

        this.linksLoaded = true;
    }
}