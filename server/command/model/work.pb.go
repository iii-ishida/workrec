// Code generated by protoc-gen-go. DO NOT EDIT.
// source: command/work.proto

package model

import (
	fmt "fmt"
	proto "github.com/golang/protobuf/proto"
	timestamp "github.com/golang/protobuf/ptypes/timestamp"
	math "math"
)

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// This is a compile-time assertion to ensure that this generated file
// is compatible with the proto package it is being compiled against.
// A compilation error at this line likely means your copy of the
// proto package needs to be updated.
const _ = proto.ProtoPackageIsVersion2 // please upgrade the proto package

type WorkPb_State int32

const (
	WorkPb_STATE_UNSPECIFIED WorkPb_State = 0
	WorkPb_UNSTARTED         WorkPb_State = 1
	WorkPb_STARTED           WorkPb_State = 2
	WorkPb_PAUSED            WorkPb_State = 3
	WorkPb_RESUMED           WorkPb_State = 4
	WorkPb_FINISHED          WorkPb_State = 5
)

var WorkPb_State_name = map[int32]string{
	0: "STATE_UNSPECIFIED",
	1: "UNSTARTED",
	2: "STARTED",
	3: "PAUSED",
	4: "RESUMED",
	5: "FINISHED",
}

var WorkPb_State_value = map[string]int32{
	"STATE_UNSPECIFIED": 0,
	"UNSTARTED":         1,
	"STARTED":           2,
	"PAUSED":            3,
	"RESUMED":           4,
	"FINISHED":          5,
}

func (x WorkPb_State) String() string {
	return proto.EnumName(WorkPb_State_name, int32(x))
}

func (WorkPb_State) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_347067fe11e1e2e4, []int{0, 0}
}

type WorkPb struct {
	Id                   string               `protobuf:"bytes,1,opt,name=id,proto3" json:"id,omitempty"`
	EventId              string               `protobuf:"bytes,2,opt,name=eventId,proto3" json:"eventId,omitempty"`
	Title                string               `protobuf:"bytes,3,opt,name=title,proto3" json:"title,omitempty"`
	Time                 *timestamp.Timestamp `protobuf:"bytes,4,opt,name=time,proto3" json:"time,omitempty"`
	State                WorkPb_State         `protobuf:"varint,5,opt,name=state,proto3,enum=model.WorkPb_State" json:"state,omitempty"`
	UpdatedAt            *timestamp.Timestamp `protobuf:"bytes,6,opt,name=updated_at,json=updatedAt,proto3" json:"updated_at,omitempty"`
	XXX_NoUnkeyedLiteral struct{}             `json:"-"`
	XXX_unrecognized     []byte               `json:"-"`
	XXX_sizecache        int32                `json:"-"`
}

func (m *WorkPb) Reset()         { *m = WorkPb{} }
func (m *WorkPb) String() string { return proto.CompactTextString(m) }
func (*WorkPb) ProtoMessage()    {}
func (*WorkPb) Descriptor() ([]byte, []int) {
	return fileDescriptor_347067fe11e1e2e4, []int{0}
}

func (m *WorkPb) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_WorkPb.Unmarshal(m, b)
}
func (m *WorkPb) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_WorkPb.Marshal(b, m, deterministic)
}
func (m *WorkPb) XXX_Merge(src proto.Message) {
	xxx_messageInfo_WorkPb.Merge(m, src)
}
func (m *WorkPb) XXX_Size() int {
	return xxx_messageInfo_WorkPb.Size(m)
}
func (m *WorkPb) XXX_DiscardUnknown() {
	xxx_messageInfo_WorkPb.DiscardUnknown(m)
}

var xxx_messageInfo_WorkPb proto.InternalMessageInfo

func (m *WorkPb) GetId() string {
	if m != nil {
		return m.Id
	}
	return ""
}

func (m *WorkPb) GetEventId() string {
	if m != nil {
		return m.EventId
	}
	return ""
}

func (m *WorkPb) GetTitle() string {
	if m != nil {
		return m.Title
	}
	return ""
}

func (m *WorkPb) GetTime() *timestamp.Timestamp {
	if m != nil {
		return m.Time
	}
	return nil
}

func (m *WorkPb) GetState() WorkPb_State {
	if m != nil {
		return m.State
	}
	return WorkPb_STATE_UNSPECIFIED
}

func (m *WorkPb) GetUpdatedAt() *timestamp.Timestamp {
	if m != nil {
		return m.UpdatedAt
	}
	return nil
}

func init() {
	proto.RegisterEnum("model.WorkPb_State", WorkPb_State_name, WorkPb_State_value)
	proto.RegisterType((*WorkPb)(nil), "model.WorkPb")
}

func init() { proto.RegisterFile("command/work.proto", fileDescriptor_347067fe11e1e2e4) }

var fileDescriptor_347067fe11e1e2e4 = []byte{
	// 290 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0x84, 0x8e, 0xc1, 0x4f, 0xc2, 0x30,
	0x14, 0xc6, 0xdd, 0xa0, 0x43, 0x1e, 0x4a, 0xe6, 0x53, 0x93, 0x86, 0x8b, 0x84, 0x13, 0x5e, 0x4a,
	0x82, 0x27, 0x8f, 0x8b, 0x2b, 0x71, 0x07, 0x09, 0x59, 0xb7, 0x78, 0x24, 0xc5, 0x56, 0xb2, 0xc0,
	0x28, 0x19, 0x45, 0xff, 0x3e, 0xff, 0x33, 0xb3, 0xce, 0x9d, 0x3d, 0x7e, 0xdf, 0xfb, 0xe5, 0xfd,
	0x3e, 0xc0, 0x0f, 0x53, 0x96, 0xf2, 0xa0, 0x66, 0xdf, 0xa6, 0xda, 0xb1, 0x63, 0x65, 0xac, 0x41,
	0x52, 0x1a, 0xa5, 0xf7, 0xa3, 0x87, 0xad, 0x31, 0xdb, 0xbd, 0x9e, 0xb9, 0x72, 0x73, 0xfe, 0x9c,
	0xd9, 0xa2, 0xd4, 0x27, 0x2b, 0xcb, 0x63, 0xc3, 0x4d, 0x7e, 0x7c, 0x08, 0xde, 0x4d, 0xb5, 0x5b,
	0x6d, 0x70, 0x08, 0x7e, 0xa1, 0xa8, 0x37, 0xf6, 0xa6, 0xfd, 0xd4, 0x2f, 0x14, 0x52, 0xe8, 0xe9,
	0x2f, 0x7d, 0xb0, 0x89, 0xa2, 0xbe, 0x2b, 0xdb, 0x88, 0x77, 0x40, 0x6c, 0x61, 0xf7, 0x9a, 0x76,
	0x5c, 0xdf, 0x04, 0x64, 0xd0, 0xad, 0xbf, 0xd3, 0xee, 0xd8, 0x9b, 0x0e, 0xe6, 0x23, 0xd6, 0xa8,
	0x59, 0xab, 0x66, 0x59, 0xab, 0x4e, 0x1d, 0x87, 0x8f, 0x40, 0x4e, 0x56, 0x5a, 0x4d, 0xc9, 0xd8,
	0x9b, 0x0e, 0xe7, 0xb7, 0xcc, 0x4d, 0x66, 0xcd, 0x1a, 0x26, 0xea, 0x53, 0xda, 0x10, 0xf8, 0x0c,
	0x70, 0x3e, 0x2a, 0x69, 0xb5, 0x5a, 0x4b, 0x4b, 0x83, 0x7f, 0x05, 0xfd, 0x3f, 0x3a, 0xb2, 0x13,
	0x09, 0xc4, 0xbd, 0xc2, 0x7b, 0xb8, 0x11, 0x59, 0x94, 0xf1, 0x75, 0xbe, 0x14, 0x2b, 0xfe, 0x92,
	0x2c, 0x12, 0x1e, 0x87, 0x17, 0x78, 0x0d, 0xfd, 0x7c, 0x29, 0xb2, 0x28, 0xcd, 0x78, 0x1c, 0x7a,
	0x38, 0x80, 0x5e, 0x1b, 0x7c, 0x04, 0x08, 0x56, 0x51, 0x2e, 0x78, 0x1c, 0x76, 0xea, 0x43, 0xca,
	0x45, 0xfe, 0xc6, 0xe3, 0xb0, 0x8b, 0x57, 0x70, 0xb9, 0x48, 0x96, 0x89, 0x78, 0xe5, 0x71, 0x48,
	0x36, 0x81, 0x5b, 0xf0, 0xf4, 0x1b, 0x00, 0x00, 0xff, 0xff, 0x5a, 0x21, 0xa6, 0x03, 0x88, 0x01,
	0x00, 0x00,
}