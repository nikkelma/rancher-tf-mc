package main

import (
	"bytes"
	"fmt"
	"io"
	"math/rand"
	"time"
)

func main() {
	sourceName, destinationName := "source.txt", "destination.txt"

	fmt.Printf("---\nBad:\n")
	MockCopyFileBad(destinationName, sourceName)

	fmt.Printf("---\nGood:\n")
	MockCopyFileGood(destinationName, sourceName)
}

const (
	openSucceed = false
	openFail    = true
)

// MockCopyFileBad implements a mock copy function that contains a subtle error
func MockCopyFileBad(dstName, srcName string) (written int64, err error) {
	src, err := MockOpen(srcName, openSucceed)
	if err != nil {
		return
	}

	dst, err := MockCreate(dstName, openFail)
	if err != nil {
		src.Close()
		return
	}

	written, err = io.Copy(dst, src)
	dst.Close()
	src.Close()
	return
}

// MockCopyFileGood implements a mock copy function that contains no subtle errors
func MockCopyFileGood(dstName, srcName string) (written int64, err error) {
	src, err := MockOpen(srcName, openSucceed)
	if err != nil {
		return
	}
	defer src.Close()

	dst, err := MockCreate(dstName, openFail)
	if err != nil {
		return
	}
	defer dst.Close()

	return io.Copy(dst, src)
}

// MockFile implements io.ReadCloser and io.WriteCloser, logging out actions
// instead of interacting with the filesystem
type MockFile struct {
	filename string
	buffer   *bytes.Buffer
}

// NewMockFile creates a mock file
func NewMockFile(filename string) *MockFile {
	contents := randSeq(100)
	mockFile := &MockFile{
		filename: filename,
		buffer:   bytes.NewBuffer([]byte(contents)),
	}
	return mockFile
}

func (f *MockFile) Read(p []byte) (n int, err error) {
	return f.buffer.Read(p)
}

func (f *MockFile) Write(p []byte) (n int, err error) {
	return f.buffer.Write(p)
}

// Close mocks closing f
func (f *MockFile) Close() error {
	fmt.Printf("closing %s\n", f.filename)
	return nil
}

// MockOpen mocks opening a file at filename, with success or failure determined
// soley by shouldFail
func MockOpen(filename string, shouldFail bool) (*MockFile, error) {
	if shouldFail {
		return nil, fmt.Errorf("open failed for file %s", filename)
	}
	fmt.Printf("opening %s\n", filename)
	return NewMockFile(filename), nil
}

// MockCreate mocks creating a file at filename, with success or failure determined
// soley by shouldFail
func MockCreate(filename string, shouldFail bool) (*MockFile, error) {
	if shouldFail {
		return nil, fmt.Errorf("create failed for file %s", filename)
	}
	fmt.Printf("creating %s\n", filename)
	return NewMockFile(filename), nil
}

// source: https://stackoverflow.com/questions/22892120/how-to-generate-a-random-string-of-a-fixed-length-in-go/22892986#22892986
// slightly modified to use a const string and bytes
const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func randSeq(n int) string {
	rand.Seed(time.Now().UnixNano())

	b := make([]byte, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}
