#!/bin/bash
# See: http://www.gimp.org/tutorials/Basic_Batch/

gimp -i -b '(batch-index-all "*.png")' -b '(gimp-quit 0)'
