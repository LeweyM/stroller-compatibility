import {Pipeline} from "../../../src/types";

enum steps {
    NUMERIC_TO_WRITTEN = "numeric to written",
    SUM_OF_NUMBERS = "sum of numbers"
}

const pipeline: Pipeline<steps> = {
   steps: [
       {
           name: steps.NUMERIC_TO_WRITTEN,
           prompt: "turn the numbers into written numbers",
           examples: [
               {
                   given: "1\n2\n3\n4\n5\n6\n7\n8\n9\n10",
                   then: "one\ntwo\nthree\nfour\nfive\nsix\nseven\neight\nnine\nten"
               }
           ]
       },
       {
           name: steps.SUM_OF_NUMBERS,
           prompt: "sum the numbers",
           examples: [
               {
                   given: "one\ntwo\nthree\nfour\nfive\nsix\nseven\neight\nnine\nten",
                   then: "55"
               }
           ]
       }
   ]
}

export default pipeline