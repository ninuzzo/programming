#lang racket
(provide number-to-string string-to-number char-to-digit
         skip-whitespaces)

(define (char-to-digit char)
  (- (char->integer char) (char->integer #\0)))

(define (skip-whitespaces (in (current-input-port)))
  (let ([next-char (peek-char in)])
    (if (char-whitespace? next-char)
        (begin (read-char in) (skip-whitespaces))
        next-char)))

#|
Convert a number in a certain base (decimal by default)
into a string, using the successive divisions algorithm.
This is akin to the built-in function number->string,
which we only use to convert a single digit.
http://docs.racket-lang.org/reference/generic-numbers.html#%28def._%28%28quote._~23~25kernel%29._number-~3estring%29%29
|#
(define (number-to-string x (base 10))
  (define (successive-division x (digits-string ""))
    (if (= x 0) digits-string
        (successive-division (quotient x base)
                             (string-append (number->string 
                                             (remainder x base)) 
                                            digits-string))))
  (if (= x 0) "0" (successive-division x)))

#|
Convert a numeric string in a certain base (decimal by default)
into a number, using Horner's development.
This is akin to the built-in function string->number:
http://docs.racket-lang.org/reference/generic-numbers.html?q=string-%3Enumber#%28def._%28%28quote._~23~25kernel%29._string-~3enumber%29%29
|#
(define (string-to-number (in (current-input-port)) (base 10))
  (define (digit-follows?)
    (define next-char (peek-char in))
    (and (not (eof-object? next-char)) (char-numeric? next-char)))
  (define (next-digit) (char-to-digit (read-char in)))
  (define (add-digit partial-number first-call)
    (if (digit-follows?)
        (add-digit (+ (* partial-number base) (next-digit)) false)
        (if first-call #f partial-number)))
  (add-digit 0 true))

(module+ test
  (require rackunit)
  
  (check-equal? (number-to-string 0) "0" "No iterations")
  (check-equal? (number-to-string 3) "3" "One digit")
  (check-equal? (number-to-string 12) "12" "Two digits")
  (check-equal? (number-to-string 123) "123" "Three digits")
  (check-equal? (number-to-string 1000) "1000" "Many zeroes")
  (check-equal? (number-to-string 1010) "1010" "Some zeroes")
  (check-equal? (number-to-string 10 2) "1010" "Base 2")
  
  (check-equal? (string-to-number (open-input-string "0")) 0 "Zero")
  (check-equal? (string-to-number (open-input-string "9")) 9
                "One digit")
  (check-equal? (string-to-number (open-input-string "123")) 123
                "Many digits")
  (check-equal? (string-to-number (open-input-string "2001")) 2001
                "Some zeroes")
  (check-equal? (string-to-number (open-input-string "1010") 2) 10
                "Base 2")
  
  (check-equal? (number-to-string (string-to-number
                                   (open-input-string "1984")))
                                  "1984" "Combined"))