package customcli

import (
	"fmt"
	"sort"
	"strings"
)

// string constants representing special tokens
const (
	// EmptyStr            = ""
	SingleApostropheStr = `'`
	SingleQuoteStr      = `"`
	TripleApostropheStr = `'''`
	TripleQuoteStr      = `"""`
	SpaceStr            = " "
	NewlineStr          = "\n"
)

// Delimiter constants used to configure delimiter arguments
const (
	delimiterUnknown delimiter = iota
	DelimiterSpace
	DelimiterNewline
)

// Quoter constants used to configure grouping arguments
const (
	quoterUnknown quoter = iota
	QuoterSingleApostrophe
	QuoterSingleQuote
	QuoterTripleApostrophe
	QuoterTripleQuote
)

var delimiterStrings = map[delimiter]string{
	DelimiterSpace:   SpaceStr,
	DelimiterNewline: NewlineStr,
}

var quoterStrings = map[quoter]string{
	QuoterSingleApostrophe: SingleApostropheStr,
	QuoterSingleQuote:      SingleQuoteStr,
	QuoterTripleApostrophe: TripleApostropheStr,
	QuoterTripleQuote:      TripleQuoteStr,
}

var defaultParser = NewParser(nil)

// delimiter defines available delimiter tokens used for separating command arguments
type delimiter uint64

// Delimiters is used to configure which delimiter tokens are used for a parser
type Delimiters map[delimiter]bool

// NewDelimiters returns a set of delimiters from the given delimiter options
func NewDelimiters(inDelimiters ...delimiter) *Delimiters {
	outDelimiters := new(Delimiters)
	for i := range inDelimiters {
		outDelimiters.addDelimiter(inDelimiters[i])
	}
	return outDelimiters
}

func (d *Delimiters) addDelimiter(in delimiter) {
	if *d == nil {
		*d = make(map[delimiter]bool)
	}
	(*d)[in] = true
}

func (d *Delimiters) hasDelimiter(in delimiter) bool {
	if d == nil {
		return false
	}
	return (*d)[in]
}

// quoter defines available quote tokens used for grouping arguments containing
// delimiter characters or quote characters
type quoter uint64

// Quoters is used to configure which quote tokens are used for a parser
type Quoters map[quoter]bool

// NewQuoters returns a set of quoters from the given quote options
func NewQuoters(inQuoters ...quoter) *Quoters {
	outQuoters := new(Quoters)
	for i := range inQuoters {
		outQuoters.addQuoter(inQuoters[i])
	}
	return outQuoters
}

func (q *Quoters) addQuoter(in quoter) {
	if *q == nil {
		*q = make(map[quoter]bool)
	}
	(*q)[in] = true
}

func (q *Quoters) hasQuoter(in quoter) bool {
	if q == nil {
		return false
	}
	return (*q)[in]
}

// ParserOptions configures a Parser.
type ParserOptions struct {
	Delimiters *Delimiters
	Quoters    *Quoters
	// TODO - define raw quoting behavior, if needed
	// RawQuoters *quoters
}

// Parser implements the Parse function and allows for configuring quote tokens
type Parser struct {
	delimiters *Delimiters
	quoters    *Quoters
	// TODO - define raw quoting behavior, if needed
	// rawQuoters *quoters
}

// NewParser returns a new parser.
func NewParser(opts *ParserOptions) *Parser {
	defaultedOpts := ParserOptions{}
	if opts != nil {
		defaultedOpts = *opts
	}

	if defaultedOpts.Delimiters == nil {
		defaultedOpts.Delimiters = NewDelimiters(DelimiterSpace, DelimiterNewline)
	}

	if defaultedOpts.Quoters == nil {
		defaultedOpts.Quoters = NewQuoters(QuoterSingleApostrophe, QuoterSingleQuote)
	}

	parser := &Parser{
		delimiters: defaultedOpts.Delimiters,
		quoters:    defaultedOpts.Quoters,
	}
	return parser
}

type parseState struct {
	index  int
	quoter quoter
}

type token struct {
	Kind          tokenKind
	Delimiter     delimiter
	Quoter        quoter
	RelativeIndex int
}

type tokenKind int

const (
	tokenKindNil tokenKind = iota
	tokenKindDelimiter
	tokenKindQuoter
)

type tokenSlice []token

// ensure tokenSlice satisfies sort.Interface
var _ sort.Interface = tokenSlice{}

func (t tokenSlice) Len() int {
	return len(t)
}

func (t tokenSlice) Less(i, j int) bool {
	switch {
	case t[j].RelativeIndex == -1:
		// sort indices of -1 to the end
		return true
	case t[i].RelativeIndex == -1:
		// sort indices of -1 to the end
		return false
	case t[i].RelativeIndex < t[j].RelativeIndex:
		// order tokens by relative index if not equal
		return true
	case t[i].Kind == tokenKindQuoter && t[j].Kind == tokenKindQuoter:
		// sort triple groupers ahead of related single groupers to make them the priority
		if t[i].Quoter == QuoterTripleApostrophe && t[j].Quoter == QuoterSingleApostrophe {
			return true
		}
		if t[i].Quoter == QuoterTripleQuote && t[j].Quoter == QuoterSingleQuote {
			return true
		}
	}
	return false
}

func (t tokenSlice) Swap(i, j int) {
	t[i], t[j] = t[j], t[i]
}

// Parse uses the Parser to split a discord message into command-line style
// arguments, similar to a traditional shell.
func (p *Parser) Parse(inString string) (args []string, err error) {
	curArg := &strings.Builder{}

	state := parseState{}
	for {
		switch {
		case state.quoter == quoterUnknown:
			// not in quoting mode: split on delimiter or switch to quoting mode
			tokens := make(tokenSlice, 0)

			for delimiter := range *p.delimiters {
				delimiterIdx := strings.Index(
					inString[state.index:],
					delimiterStrings[delimiter])
				tokens = append(tokens, token{
					Kind:          tokenKindDelimiter,
					Delimiter:     delimiter,
					RelativeIndex: delimiterIdx,
				})
			}
			for quoter := range *p.quoters {
				quoterIdx := strings.Index(inString[state.index:], quoterStrings[quoter])
				tokens = append(tokens, token{
					Kind:          tokenKindQuoter,
					Quoter:        quoter,
					RelativeIndex: quoterIdx,
				})
			}

			// sort tokens so triple tokens are prioritized above single tokens of the
			// same character
			sort.Sort(tokens)

			minToken := token{}
			if tokens.Len() > 0 && tokens[0].RelativeIndex != -1 {
				minToken = tokens[0]
			}

			switch minToken.Kind {
			case tokenKindDelimiter:
				// if content was found between delimiters, add to current argument
				if minToken.RelativeIndex != 0 {
					start, end := state.index, state.index+minToken.RelativeIndex
					curArg.WriteString(inString[start:end])
				}
				// if current argument is non-empty, add to argument list and reset
				// current argument
				if curArg.Len() > 0 {
					args = append(args, curArg.String())
					curArg.Reset()
				}
				state.index += minToken.RelativeIndex + len(delimiterStrings[minToken.Delimiter])

			case tokenKindQuoter:
				// if content was found between quotes, add to current argument
				if minToken.RelativeIndex != 0 {
					start, end := state.index, state.index+minToken.RelativeIndex
					curArg.WriteString(inString[start:end])
				}
				state.quoter = minToken.Quoter
				state.index += minToken.RelativeIndex + len(quoterStrings[minToken.Quoter])

			default:
				// no tokens of importance found, end parsing
				curArg.WriteString(inString[state.index:])
				// if current argument is non-empty, add to argument list
				if curArg.Len() > 0 {
					args = append(args, curArg.String())
				}
				return
			}
		default:
			// in quoting mode: look for matching ending quoting token
			quoterString := quoterStrings[state.quoter]
			endQuoteIdx := strings.Index(inString[state.index:], quoterString)
			if endQuoteIdx < 0 {
				err = fmt.Errorf("found unmatched quote <%s>", quoterString)
				return
			}
			start, end := state.index, state.index+endQuoteIdx
			curArg.WriteString(inString[start:end])
			state.quoter = quoterUnknown
			state.index += endQuoteIdx + len(quoterString)
		}
	}
}

// Parse uses a default Parser to split a discord message into arguments. For
// finer control, create a Parser and call its Parse method.
func Parse(s string) ([]string, error) {
	return defaultParser.Parse(s)
}
