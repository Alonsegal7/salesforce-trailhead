import {LightningElement,track} from "lwc";

export default class calcEndDate extends LightningElement {
    @track StartDate;
    @track Duration;
    @track EndDate;

    addDuration(dt, dur){
        var temp = new Date(dt);
        console.log('addDuration dt: '+ temp);
        console.log('addDuration dur: '+ dur);
        console.log('addDuration getMonth: '+ temp.getMonth());
        console.log('addDuration total months to add: '+ parseInt(temp.getMonth()) + parseInt(dur));
        temp.setMonth(parseInt(temp.getMonth()) + parseInt(dur));
        //date.setDate(date.getDate() + 1)
        console.log('addDuration post set: '+ temp);
        return temp;
    }
    deductDays(dt,days){
        var temp = new Date(dt);
        temp = dt.getDate() - days;
        dt.setDate(temp);
        console.log(temp);
        return temp;

    }
    calcExpr() {
        try{
            this.EndDate = this.addDuration(this.StartDate, this.Duration);
            this.EndDate=this.deductDays(this.EndDate,1);
        } catch(e){
            console.error(e);
            console.error('e.name => ' + e.name );
            console.error('e.message => ' + e.message );
            console.error('e.stack => ' + e.stack );
        }
    }
    handleChangeDate(evt) {
        this.StartDate = evt.target.value;
        if (this.StartDate != null && this.Duration != null){
            this.calcExpr();
        }
    }

    handleChangeDuration(evt) { 
        this.Duration = evt.target.value;
        if (this.StartDate != null && this.Duration != null){
            this.calcExpr();
        }
    }
}

