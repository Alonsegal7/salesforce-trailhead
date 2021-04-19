import { LightningElement, track, wire } from 'lwc';
import getTargets from '@salesforce/apex/aeAndTargetsMatrix.getPeriods';
import getPeriods from '@salesforce/apex/aeAndTargetsMatrix.getTargetsMatrix';

export default class TargetsManager extends LightningElement{
    @track targetsDict={};
    @track periods;
    @track messages=[];
    @track periodColumns=getTableColumns();
    /*@track responseByWeekDayColumns=[{label: 'Week Day', fieldName: 'weekday'},
                                     {label: '# of Messages', fieldName: 'messages', type: 'number'},
                                     {label: '# of Responses', fieldName: 'responses', type: 'number'},
                                     {label: 'Average Response Time (Hours)', fieldName: 'avgResponseTime', type: 'number'},
                                     {label: 'Median Response Time (Hours)', fieldName: 'medianResponseTime', type: 'number'}];*/
    @track errorMessage;
    
    @wire(getTargets, {})
    getTargetsDictionary(result){
        if (result.data){
            this.errorMessage=undefined;
            let dict={};
            var conts = result.data;
            for(var key in conts){
                this.targetsDict.push({value:conts[key], key:key});
            }
            console.log('Raz Ben Ron TM targetsDict: '+targetsDict);
            //this.targetsDict=dict;
            this.messages=[];
        }
        else{
            this.errorMessage=JSON.stringify(result.error);
        }
    }
    @wire(getPeriods)
    getPeriodsList({data, error}){
            if(data){
                this.periods = data;                
                this.error = undefined;
            }
            else if (error) {
                this.error = error;
                this.accounts = undefined;
            }
        }
    getTableColumns(){
        this.periodColumns.push('AE Name');
        for(var per in this.periods){
            this.periodColumns.push(per);
        }
    }
    
    
}