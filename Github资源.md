### Github资源

https://github.com/anseki/leader-line

[LeaderLine](https://anseki.github.io/leader-line/)



  

### SAP Workflow Table

Table HRS1201 has info on tasks and methods

And table hrs1205 has the info of the active version of the workflow.



the main header table is SWWWIHEAD, other related tables are named SWW*.

There are also quite many standard functions available for reporting, please check fm:s SAP_WAPI_GET* and SAP_WAPI_WORKITEM* for more reference.



See the package SWW in SE80 , you will get all sap objects ( tables , function group ,etc ) w.r.t workflow



Some important tables

SWWWIHEAD, SWWUSERWI

Txn: SWI1, SWUD, SWUE, SWUS, SWI2_DIAG, SWEL , SWELS.......



Please find some important tables below....

SWEINSTCOU : Instance Linkage Event u2013 Receiver

SWFDEVINST : Event Linkages with Instance Reference

SWW_CONTOB : Work Item Data Container (WI to Business Objects)

SWW_CONT : Workflow Runtime: Work Item Data Container

SWWORGTASK : Assignment of WIs to Org. Unit/Task (WI to Task)

SWWWIHEAD : Header Table for All Work Item Types

SWW_WI2OBJ : Workitem form Bus Object Key ( e.g. Material No )

SWWLOGHIST : History of a Work Item

SWW_OUTBOX : DB View for Selection of Outbox ( WI text, WI stat etc)

SWWUSERWI : Current Work Items Assigned to a User

HRP1001 : Infotype 1001 DB Table ( Resp to Org Obj )

HRP1240 : DB Table for Infotype 1240 ( Resp to Rule )

HRP1217 : Infotype 1217 DB Table ( All Task Details )

AGR_USERS : Assignment of roles to users

HRSOBJECT : Index for Standard Objects ( e.g. All running workflows )

SWETYPECOU : Type Linkage Events u2013 Receiver

SWFDEVENA : Activations for Event Linkages

SWFDEVTYP : Event Linkages Without Instance Reference

SWETYPEENA : Type Linkage Events - Receiver: Activation Table



also check package SWT in se80, there are function modules and stuff.

But why are you using the workflow trace (SWU10)?

I always thought this is extremely resources consuming and should only be used in rare and temporary cases.

I might also be completely disinformed about this :P



What didn't they like about the SAP standard transaction for showing information?

Also why do you need the workflow trace?

I usually train managers in the usage of SWI5, which is enough in most cases to get information on the usage of workflows in their production system.
