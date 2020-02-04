---
layout: post
title:  Palindrome Day
date:   2020-02-02 23:29 +0100
image:  newtons-cradle-256213_1280.jpg
credit: https://pixabay.com/de/photos/newtons-wiege-eier-kugel-aktion-256213/
tags:   code java
---

> With palindromic number comes palindrome day. A Palindrome day which happens when the day’s date is observed be same when digits are reversed. 2 February 2020 is a palindrome day and most unique palindrome day as this day can be observed regardless of the date format by country because regardless of the dd-mm-yy or mm-dd-yy format. -- [Wikipedia](https://en.wikipedia.org/wiki/Palindrome#Numbers)

To verify the palindrome day I wrote a Java programm:

{% highlight java %}
package net.choas.java;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class PalindromeDay {

  public static void main(String args[]) throws ParseException {
    String date;
    Boolean result;

    date = "02.02.2020";
    System.out.println(date + "?");
    result = isPalindrome(date);
    System.out.println(result + "\n");

    date = "20.02.2002";
    System.out.println(date + "?");
    result = isPalindrome(date);
    System.out.println(result + "\n");

    date = "02-20-2002";
    System.out.println(date + "?");
    result = isPalindrome(date);
    System.out.println(result + "\n");
  }

  public static Boolean isPalindrome(String date) throws ParseException {
    String str = date.replace(".", "").replace("-", "");
    String strReverse = new StringBuilder(str).reverse().toString();

    SimpleDateFormat sdfEU = new SimpleDateFormat("ddMMyyyy");
    Date dateEU = sdfEU.parse(str);
    Date dateEUreverse = sdfEU.parse(strReverse);

    SimpleDateFormat sdfUS = new SimpleDateFormat("MMddyyyy");
    Date dateUS = sdfUS.parse(str);
    Date dateUSreverse = sdfUS.parse(strReverse);

    SimpleDateFormat sdfEUOut = new SimpleDateFormat("dd.MM.yyyy");
    SimpleDateFormat sdfUSOut = new SimpleDateFormat("MM-dd-yyyy");

    System.out.println("  EU: " + 
              sdfEUOut.format(dateEU) + 
              " " + 
              sdfEUOut.format(dateEUreverse));
    System.out.println("  US: " + 
              sdfUSOut.format(dateUS) + 
              " " + 
              sdfEUOut.format(dateUSreverse));

    return dateEU.equals(dateEUreverse) && 
        dateUS.equals(dateUSreverse) && 
        dateEU.equals(dateUS);
  }
}
{% endhighlight %}

The _isPalindrome_ function takes the date and removes all dots and dashes. Based on this a reverse string is generated. Then a _SimpleDateFormat_ for "ddMMyyyy" and "MMddyyyy" converts both strings into a date. They are printed and at the end compared to each other to see if they are equal in their format and with the other. A palindrome tag returns "true".

Here is the result for the test data in the _main_ function:

```text
02.02.2020?
  EU: 02.02.2020 02.02.2020
  US: 02-02-2020 02.02.2020
true

20.02.2002?
  EU: 20.02.2002 20.02.2002
  US: 08-02-2003 02.08.2003
false

02-20-2002?
  EU: 02.08.2003 20.02.0220
  US: 02-20-2002 02.08.0221
false
```

<br />
The following code finds all palindrome days within 10,000 years:

{% highlight java %}
Date d = new Date(-1900, 0, 1);
while (d.getYear() < 10000 - 1900) {
  d.setDate(d.getDate() + 1);
  SimpleDateFormat sdfOut = new SimpleDateFormat("dd.MM.yyyy");
  if (isPalindrome(sdfOut.format(d))) {
    System.out.println(sdfOut.format(d));
  }
}
{% endhighlight %}

... and this is the result:

```text
10.10.0101
01.01.1010
11.11.1111
02.02.2020
12.12.2121
03.03.3030
04.04.4040
05.05.5050
06.06.6060
07.07.7070
08.08.8080
09.09.9090
```

<br />
What happened that day? The Kansacity Chiefs 🏈 have won the Superbowl (US time) and are perhaps the only ones who have ever won it on a palindrome day.
