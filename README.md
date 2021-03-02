# auditCheckR
To perform quick analysis and checks on audit csv files

`devtools::install_github("hedibmustapha/auditCheckR")`

`library(auditCheckR)`

**res<-auditcheck(pathtofolder = "audit/")**

**res<-auditcheck(pathtofolder = "audit/", excluded= c("q0_gps","note_intro","consensus_note"))**
## arguments
**pathtofolder**: where all your audit folders are stored (every audit folder should have an uuid name)

**excluded**: If you don't want to take into consideration some variable in the survey duration check, please specify the **XML** variables names
## Output
The output is a dataframe with the following variables:

*uuid*

*start_to_exit*: survey duration from its creation until the user exit the form

*time_on_questions*: amount of time that the enumerator spent on answering the questions

*time_on_filterd_questions*: if you have used the **excluded** argument, this variable returns difference between time_on_questions and time spent answering excluded variables

*jump*: how many times enumerator has viewed the jump screen

*endscreen*: how many times enumerator has viewed the end screen

*formsave*: how many times enumerator has saved the form

*formexit*: how many times enumerator has exited the form

*formresume*: how many times enumerator has resumed the form

*formfinalize*: how many times enumerator has finalized the form

*saveerror*: how many times enumerator has faced an error while trying to save
