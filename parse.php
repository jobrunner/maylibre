#!/usr/bin/env php
<?php

$isbnString = "9782920718944";
$isbn       = new Isbn($isbnString);

$isbn->NSDictionary();
exit;

$formatter = new IsbnFormatter();

echo "\n";
echo "Formattiert: " . $formatter->format($isbn);
echo "\n";
exit;


class Isbn
{
    public static $config;
    public static $messageSource;
    public static $messageSerialNumber;
    public static $messageDate;

    public $prefix;
    public $groupNumber;
    public $publishingNumber;
    public $titleNumber;
    public $checkSum;
    public $isbn;


    public function __construct($isbn)
    {
        if (static::$config == null) {
           static::$config = static::loadConfig();
        }
        $this->isbn             = $this->normalizeIsbn($isbn);
        $this->prefix           = $this->findPrefix();
        $this->groupNumber      = $this->findGroupNumber();
        $this->publishingNumber = $this->findPublishingNumber();
        $this->titleNumber      = $this->findTitleNumber();
        $this->checkSum         = $this->findCheckSum();
    }

    public static function loadConfig()
    {
        $url = sys_get_temp_dir() . DIRECTORY_SEPARATOR . "export_rangemessage.xml";
//        echo $url;
//        echo "\n";
//        exit;
        $xml = @simplexml_load_file($url);

        if ($xml == null) {
            $remoteUrl = 'https://www.isbn-international.org/export_rangemessage.xml';
            $xml = @simplexml_load_file($remoteUrl);
            $xml->saveXML($url);
        }

        static::$messageSource = (string)$xml->xpath("/ISBNRangeMessage/MessageSource")[0];
        static::$messageSerialNumber = (string)$xml->xpath("/ISBNRangeMessage/MessageSerialNumber")[0];
        static::$messageDate = (string)$xml->xpath("/ISBNRangeMessage/MessageDate")[0];

        $elements = $xml->xpath("/ISBNRangeMessage/RegistrationGroups/*");

        $lexicon = [];
        foreach ($elements as $element) {
            $prefix = (string)$element->Prefix;
            $prefix = str_replace('-', '', $prefix);
            // $agency = (string)$element->Agency;
            foreach ($element->Rules as $rule) {
                foreach ($rule as $i) {
                    $len = (int)$i->Length;
                    if ($len > 0) {
                        list($lower, $upper) = explode('-', $i->Range);
                        $lexicon[$prefix][] = ['len' => (int)$len,
                                               'lo'  => (int)substr($lower, 0, $len),
                                               'hi'  => (int)substr($upper, 0, $len)];



                    }
                }
            }
        }

//        echo json_encode($lexicon, JSON_PRETTY_PRINT);

        return $lexicon;
    }

    public function NSDictionary()
    {
        $dict = static::$config;
        $lastIndex = count($dict) - 1;
        $index = 0;

        echo "//\n";
        echo "// MayISBNRangeDictionary.m\n";
        echo "//\n";
        echo "@import Foundation;\n\n";
        echo "#include \"MayISBNRangeDictionary.h\"\n\n";
        echo "@implementation MayISBNRangeDictionary\n\n";

        echo "/**\n";
        echo " * ISBNRangeMessage" . "\n";
        echo " * MessageSource: " . static::$messageSource . "\n";
        echo " * MessageSerialNumber: " . static::$messageSerialNumber . "\n";
        echo " * MessageDate: " . static::$messageDate . "\n";
        echo " */\n";
        echo "+ (NSDictionary *)rangeDictionary {\n\n";
        echo "    return @{\n";
        foreach ($dict as $groupKey => $rules) {
            echo "                             ";
            echo "@\"$groupKey\":";
            echo str_pad("", 8 - strlen($groupKey), " ") . "@[";
            $this->rules($rules);
            echo "]";

            if ($lastIndex == $index) {
            } else {
                echo ",\n\n";
            }
            $index++;
        }
        echo "    };\n";
        echo "};\n\n";
        echo "@end";
        exit;
    }

    public function rules($rules)
    {
        $lastIndex = count($rules) - 1;
        $index = 0;
        foreach ($rules as $rule) {
            if ($index != 0) {
                echo "                                         ";
            }

            printf("@{@\"len\":@(%u),@\"lo\":@%u,@\"hi\":@%u}", $rule['len'], $rule['lo'], $rule['hi']);

            if ($lastIndex == $index) {

            } else {
                echo ",\n";

            }
            $index++;
        }
    }

    public static function isbnFromString($isbn)
    {

        $instance = new self($isbn);

        return $instance;
    }

    public function normalizeIsbn($isbn)
    {
        return str_replace('-', '', $isbn);
    }

    public function findPrefix()
    {
        return substr($this->isbn, 0, 3);
    }

    /**
     * Looking up group number for given isbn
     *
     * @param $isbn
     *
     * @return null|string
     */
    public function findGroupNumber()
    {
        $matches = static::$config;

        for ($len = 3; $len < 13; $len++) {
            $searchKey = substr($this->isbn, 0, $len);

            $matches   = array_filter($matches, function($key) use ($searchKey) {
                return (false !== strstr($key, $searchKey));
            }, ARRAY_FILTER_USE_KEY);

            $count = count($matches);

            if ($count == 0) {
                return null;
            }

            if ($count == 1) {
                return substr($searchKey, 3);
            }
        }

        return null;
    }

    public function findPublishingNumber()
    {
        $rules         = static::$config[$this->prefix . $this->groupNumber];
        $startPosition = strlen($this->prefix . $this->groupNumber);
        $heystack      = substr($this->isbn, $startPosition);

        foreach ($rules as $rule) {
            $value = (int)substr($heystack, 0, $rule['len']);
            if ($value >= $rule['lo'] && $value <= $rule['hi']) {
                return $value;
                break;
            }
        }

        return null;
    }

    public function findTitleNumber()
    {
        $position = strlen($this->prefix . $this->groupNumber . $this->publishingNumber);

        if ($position > 3) {
            return substr($this->isbn, $position, 13 - $position - 1);
        }

        return null;
    }

    public function findCheckSum()
    {
        return substr($this->isbn, 12, 1);
    }
}

class IsbnFormatter
{
    public function format(Isbn $isbn)
    {
        return sprintf("%s-%s-%s-%s-%s",
            $isbn->prefix,
            $isbn->groupNumber,
            $isbn->publishingNumber,
            $isbn->titleNumber,
            $isbn->checkSum);
    }
}
