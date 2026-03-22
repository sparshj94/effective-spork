import { LightningElement, wire } from 'lwc'; import saveUserRecord from '@salesforce/apex/QuizController.saveAttendee' 
import getQuizQuestions from '@salesforce/apex/QuizController.getQuizQuestions'; 
export default class ELearningPlatform extends LightningElement { 
    firstName; 
    lastName; 
    email; 
    showStartQuizButton = false; 
    isToDisplayQuestions = false; 
    isFinishButtonToDisplay = false; 
    questionsFromDb = []; 
    currentQuestionIndex = 0; 
    currentQuestion; 
    questionName; 
    options; 
    selectedAnswers = {}; 
    score=0;
    reviewQuestions = [];
    isDisplayReviewButton = false;
    // isSeeAnswerButton = false;
    questionNeedsReview  = false;
    wantToSeeAnswer = false;
    currentReviewIndex=0;
    reviewQuestionName;
    reviewUserAns;
    reviewCorrectAns;
    isQuestionCorrect;
    disPlayThankMessage = false;
    isHideNextButton = false;
    isUserFormDisplay = true;
    error;
    @wire(getQuizQuestions) getQuestions({error, data}){ if(data){ this.questionsFromDb = data; } } 
    handleUserSave(){ 
        this.firstName = this.template.querySelector('.firstname').value; 
        this.lastName = this.template.querySelector('.lastname').value; 
        this.email = this.template.querySelector('.email').value; 
        saveUserRecord({'firstName':this.firstName, 'lastName':this.lastName, 'email':this.email}).then(result=>{ 
            this.isUserFormDisplay = false; 
            this.showStartQuizButton = true; 
        }).catch(error=>{ 
            this.error = error; 
        }) 
    }
    startQuiz(){ 
        if(this.questionsFromDb.length === 0){
            return;
        }
        this.showStartQuizButton = false;
        this.isToDisplayQuestions = true; 
        this.updatedCurrentQuestion();
    } 
    handleChange(event){ 
        const userOption = event.detail.value; 
        const quesId = this.currentQuestion.Id; 
        if(!quesId) return 
        this.selectedAnswers[quesId] = userOption; 
        const aw = JSON.parse(JSON.stringify(this.selectedAnswers));
    } 
    get value(){ 
        return this.selectedAnswers[this.currentQuestion?.Id]; 
    } 
    updatedCurrentQuestion(){ 
        this.currentQuestion = this.questionsFromDb[this.currentQuestionIndex]; 
        this.questionName = this.currentQuestion?.Name; 
        
        
        const op1 = this.currentQuestion.OptionA__c; 
        const op2 = this.currentQuestion.OptionB__c; 
        const op3 = this.currentQuestion.OptionC__c; 
        const op4 = this.currentQuestion.OptionD__c; 
        // console.log(op1, op2, op3, op4);
        this.options = [ 
            { label: op1, value: op1 },
            { label: op2, value: op2 },
            { label: op3, value: op3 },
            { label: op4, value: op4 }
        ]
        if(this.currentQuestionIndex=== this.questionsFromDb.length-1){
            this.isFinishButtonToDisplay = true;
            this.isHideNextButton = true;
        }        
    }

    handlePrevious(){ 
        if(this.currentQuestionIndex> 0 && this.questionsFromDb.length > 0){ 
            this.currentQuestionIndex--; 
            this.updatedCurrentQuestion(); 
        } 
    } 
    handleNext(){ 
        if(this.currentQuestionIndex < this.questionsFromDb.length -1){ 
            this.currentQuestionIndex++; 
            this.updatedCurrentQuestion();
        }
    } 

    updateCurrentReviewQuestion(){
        const currentReviewQuestion = this.reviewQuestions[this.currentReviewIndex];
        if(!currentReviewQuestion){
            return;
        }
        this.reviewQuestionName = currentReviewQuestion.question;
        this.reviewUserAns=currentReviewQuestion.userAns;
        this.reviewCorrectAns = currentReviewQuestion.correctAns;
        this.isQuestionCorrect = currentReviewQuestion.isCorrect;
        if(this.currentReviewIndex===this.reviewQuestions.length-1){
            this.disPlayThankMessage = true;
        }
    }
    
    handleReviewNext(){
        if(this.currentReviewIndex < this.reviewQuestions.length-1){
            this.currentReviewIndex++;
            this.updateCurrentReviewQuestion();
            this.wantToSeeAnswer = false;
        }
        if(this.currentReviewIndex===this.reviewQuestions.length-1){
            this.questionNeedsReview = false;
            this.disPlayThankMessage = true;
        }
    }
    handleFinish(){
        this.calculateAndPrepareData();
        this.isToDisplayQuestions = false;
        this.isDisplayReviewButton = true;
        //display score and review button
    }

    handleReview(){
        // console.log(this.score);
        this.isDisplayReviewButton = false;
        this.questionNeedsReview = true;
        this.updateCurrentReviewQuestion()
        // console.log('revi clikcedp');
        
    }
    seeAnswer(){
        this.wantToSeeAnswer = true;
    }

    calculateAndPrepareData(){
        this.questionsFromDb.forEach(ques=>{
            const correctAns = ques.Correct_Answer__c;
            const userAns = this.selectedAnswers[ques.Id];
            const isCorrect = correctAns===userAns;
            if(isCorrect){
                this.score++;
            }
            this.reviewQuestions.push({
                question:ques.Name,
                userAns:userAns ? userAns : 'Not Answered',
                correctAns:correctAns,
                isCorrect:isCorrect
            })
            // console.log('revv',this.reviewQuestions);
            
        })
        // console.log('answ data', this.reviewQuestions);
        
    }

    get computeClass(){
        return `slds-p-around_large ${this.isQuestionCorrect ? 'slds-text-color_success' : 'slds-text-color_error'}`;
    }
}