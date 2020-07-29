package customcli

import (
	"fmt"
	"testing"
)

type parserTestCase struct {
	Parser      *Parser
	Input       string
	Expected    []string
	ExpectedErr bool
}

type parserTestCaseResult struct {
	parserTestCase
	Actual    []string
	ActualErr error
}

func strSliceIsEqual(x, y []string) bool {
	if len(x) != len(y) {
		return false
	}
	for i := range x {
		if x[i] != y[i] {
			return false
		}
	}
	return true
}

func TestNewParser(t *testing.T) {
	// var parser,
}

func TestParser(t *testing.T) {
	parserSpaces := NewParser(&ParserOptions{
		Delimiters: NewDelimiters(DelimiterSpace),
	})

	parserTripleQuote := NewParser(&ParserOptions{
		Quoters: NewQuoters(QuoterTripleQuote),
	})

	parserSingleTripleQuote := NewParser(&ParserOptions{
		Quoters: NewQuoters(QuoterSingleQuote, QuoterTripleQuote),
	})
	parserSingleTripleApostrophe := NewParser(&ParserOptions{
		Quoters: NewQuoters(QuoterSingleApostrophe, QuoterTripleApostrophe),
	})

	cases := []parserTestCase{
		{
			Parser:   parserSpaces,
			Input:    "a b\nc",
			Expected: []string{"a", "b\nc"},
		},
		{
			Parser:   parserTripleQuote,
			Input:    `a b """c"""`,
			Expected: []string{"a", "b", "c"},
		},
		{
			Parser:      parserTripleQuote,
			Input:       `a b "c"""`,
			ExpectedErr: true,
		},
		{
			Parser:   parserTripleQuote,
			Input:    `a b """c"""`,
			Expected: []string{"a", "b", "c"},
		},
		{
			Parser:   parserSingleTripleQuote,
			Input:    `a b """c"c"""`,
			Expected: []string{"a", "b", `c"c`},
		},
		{
			Parser:   parserSingleTripleApostrophe,
			Input:    `a b '''c'c'''`,
			Expected: []string{"a", "b", "c'c"},
		},
	}

	results := make([]parserTestCaseResult, 0, len(cases))

	for i := range cases {
		results = append(results, parserTestCaseResult{parserTestCase: cases[i]})
		fmt.Printf("== TestParser case %d==\n", i)
		results[i].Actual, results[i].ActualErr = cases[i].Parser.Parse(cases[i].Input)
	}

	for i := range results {
		switch {
		case results[i].ExpectedErr:
			if results[i].ActualErr == nil {
				t.Errorf(
					"case %d: expected non-nil error, got nil error\n",
					i,
				)
			}
		case results[i].ActualErr != nil:
			t.Errorf(
				"case %d: unexpected error: %s\n",
				i,
				results[i].ActualErr,
			)
		case !strSliceIsEqual(results[i].Expected, results[i].Actual):
			t.Errorf(
				"case %d: expected %q, got %q\n",
				i,
				results[i].Expected,
				results[i].Actual,
			)
		default:
		}
	}
}

func TestParse(t *testing.T) {
	cases := []parserTestCase{
		{
			Input:    `a b c`,
			Expected: []string{"a", "b", "c"},
		},
		{
			Input:    "a b\nc",
			Expected: []string{"a", "b", "c"},
		},
		{
			Input:    `a bb "ccc"`,
			Expected: []string{"a", "bb", "ccc"},
		},
		{
			Input:    `a bb   ccc`,
			Expected: []string{"a", "bb", "ccc"},
		},
		{
			Input:    `a bb c"cc"`,
			Expected: []string{"a", "bb", "ccc"},
		},
		{
			Input:    `a bb c"c"c""`,
			Expected: []string{"a", "bb", "ccc"},
		},
		{
			Input:    `a bb "c'c'c"`,
			Expected: []string{"a", "bb", "c'c'c"},
		},
		{
			Input:       `a bb "ccc`,
			ExpectedErr: true,
		},
		{
			Input:    `a bb "c` + "\n" + `cc"`,
			Expected: []string{`a`, `bb`, "c\ncc"},
		},
		{
			Input:       `a bb ccc"`,
			ExpectedErr: true,
		},
		{
			Input:    `a bb cçć`,
			Expected: []string{"a", "bb", "cçć"},
		},
		{
			Input:    `a bb ć"ç"ć`,
			Expected: []string{"a", "bb", "ćçć"},
		},
		{
			Input:    `a bb ccc  `,
			Expected: []string{"a", "bb", "ccc"},
		},
	}

	results := make([]parserTestCaseResult, 0, len(cases))

	for i := range cases {
		results = append(results, parserTestCaseResult{parserTestCase: cases[i]})
		fmt.Printf("== TestParse case %d==\n", i)
		results[i].Actual, results[i].ActualErr = Parse(cases[i].Input)
	}

	for i := range results {
		switch {
		case results[i].ExpectedErr:
			if results[i].ActualErr == nil {
				t.Errorf(
					"case %d: expected non-nil error, got nil error\n",
					i,
				)
			}
		case results[i].ActualErr != nil:
			t.Errorf(
				"case %d: unexpected error: %s\n",
				i,
				results[i].ActualErr,
			)
		case !strSliceIsEqual(results[i].Expected, results[i].Actual):
			t.Errorf(
				"case %d: expected %q, got %q\n",
				i,
				results[i].Expected,
				results[i].Actual,
			)
		default:
		}
	}
}
