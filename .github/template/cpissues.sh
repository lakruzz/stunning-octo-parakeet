#!/bin/sh

REPOROOT=$(git rev-parse --show-toplevel)
TEMPLATEDIR=$REPOROOT/.github/template
TEMPLATECONFIG=$TEMPLATEDIR/gitconfig
TEMPLATELABEL=$(git config -f $TEMPLATECONFIG template.issue-label)
TEMPLATEREPO=$(git config -f $TEMPLATECONFIG template.repo)
TEMPLATEISSUES=$TEMPLATEDIR/issues.json
TMPFILE=$TEMPLATEDIR/tmp-body.md
CLEANUP=

cd $REPOROOT

[ -e $TEMPLATEISSUES ] || CLEANUP="rm $TEMPLATEISSUES"
[ -e $TEMPLATEISSUES ] || gh issue list --label $TEMPLATELABEL -R $TEMPLATEREPO --json 'title,body' > $TEMPLATEISSUES

for row in $(cat $TEMPLATEISSUES | jq -r '.[] | @base64'); do
    _jq() { 
     echo ${row} | base64 --decode | jq -r ${1}
    }
   echo $(_jq '.body') > $TMPFILE
   cmd="gh issue create --title \"$(_jq '.title')\" --body-file $TMPFILE"
   echo $cmd
   eval $cmd
   rm $TMPFILE
done

eval $CLEANUP
