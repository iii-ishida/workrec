// Code generated by protoc-gen-go. DO NOT EDIT.
// source: worklist.proto

package model

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"
import timestamp "github.com/golang/protobuf/ptypes/timestamp"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// This is a compile-time assertion to ensure that this generated file
// is compatible with the proto package it is being compiled against.
// A compilation error at this line likely means your copy of the
// proto package needs to be updated.
const _ = proto.ProtoPackageIsVersion2 // please upgrade the proto package

type WorkListItemPb_State int32

const (
	WorkListItemPb_STATE_UNSPECIFIED WorkListItemPb_State = 0
	WorkListItemPb_UNSTARTED         WorkListItemPb_State = 1
	WorkListItemPb_STARTED           WorkListItemPb_State = 2
	WorkListItemPb_PAUSED            WorkListItemPb_State = 3
	WorkListItemPb_RESUMED           WorkListItemPb_State = 4
	WorkListItemPb_FINISHED          WorkListItemPb_State = 5
)

var WorkListItemPb_State_name = map[int32]string{
	0: "STATE_UNSPECIFIED",
	1: "UNSTARTED",
	2: "STARTED",
	3: "PAUSED",
	4: "RESUMED",
	5: "FINISHED",
}
var WorkListItemPb_State_value = map[string]int32{
	"STATE_UNSPECIFIED": 0,
	"UNSTARTED":         1,
	"STARTED":           2,
	"PAUSED":            3,
	"RESUMED":           4,
	"FINISHED":          5,
}

func (x WorkListItemPb_State) String() string {
	return proto.EnumName(WorkListItemPb_State_name, int32(x))
}
func (WorkListItemPb_State) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_worklist_4171545308b7c143, []int{1, 0}
}

type WorkListPb struct {
	Works                []*WorkListItemPb `protobuf:"bytes,1,rep,name=works,proto3" json:"works,omitempty"`
	NextPageToken        string            `protobuf:"bytes,2,opt,name=next_page_token,json=nextPageToken,proto3" json:"next_page_token,omitempty"`
	XXX_NoUnkeyedLiteral struct{}          `json:"-"`
	XXX_unrecognized     []byte            `json:"-"`
	XXX_sizecache        int32             `json:"-"`
}

func (m *WorkListPb) Reset()         { *m = WorkListPb{} }
func (m *WorkListPb) String() string { return proto.CompactTextString(m) }
func (*WorkListPb) ProtoMessage()    {}
func (*WorkListPb) Descriptor() ([]byte, []int) {
	return fileDescriptor_worklist_4171545308b7c143, []int{0}
}
func (m *WorkListPb) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_WorkListPb.Unmarshal(m, b)
}
func (m *WorkListPb) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_WorkListPb.Marshal(b, m, deterministic)
}
func (dst *WorkListPb) XXX_Merge(src proto.Message) {
	xxx_messageInfo_WorkListPb.Merge(dst, src)
}
func (m *WorkListPb) XXX_Size() int {
	return xxx_messageInfo_WorkListPb.Size(m)
}
func (m *WorkListPb) XXX_DiscardUnknown() {
	xxx_messageInfo_WorkListPb.DiscardUnknown(m)
}

var xxx_messageInfo_WorkListPb proto.InternalMessageInfo

func (m *WorkListPb) GetWorks() []*WorkListItemPb {
	if m != nil {
		return m.Works
	}
	return nil
}

func (m *WorkListPb) GetNextPageToken() string {
	if m != nil {
		return m.NextPageToken
	}
	return ""
}

type WorkListItemPb struct {
	Id                   string               `protobuf:"bytes,1,opt,name=id,proto3" json:"id,omitempty"`
	Title                string               `protobuf:"bytes,2,opt,name=title,proto3" json:"title,omitempty"`
	State                WorkListItemPb_State `protobuf:"varint,3,opt,name=state,proto3,enum=WorkListItemPb_State" json:"state,omitempty"`
	CreatedAt            *timestamp.Timestamp `protobuf:"bytes,4,opt,name=created_at,json=createdAt,proto3" json:"created_at,omitempty"`
	UpdatedAt            *timestamp.Timestamp `protobuf:"bytes,5,opt,name=updated_at,json=updatedAt,proto3" json:"updated_at,omitempty"`
	XXX_NoUnkeyedLiteral struct{}             `json:"-"`
	XXX_unrecognized     []byte               `json:"-"`
	XXX_sizecache        int32                `json:"-"`
}

func (m *WorkListItemPb) Reset()         { *m = WorkListItemPb{} }
func (m *WorkListItemPb) String() string { return proto.CompactTextString(m) }
func (*WorkListItemPb) ProtoMessage()    {}
func (*WorkListItemPb) Descriptor() ([]byte, []int) {
	return fileDescriptor_worklist_4171545308b7c143, []int{1}
}
func (m *WorkListItemPb) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_WorkListItemPb.Unmarshal(m, b)
}
func (m *WorkListItemPb) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_WorkListItemPb.Marshal(b, m, deterministic)
}
func (dst *WorkListItemPb) XXX_Merge(src proto.Message) {
	xxx_messageInfo_WorkListItemPb.Merge(dst, src)
}
func (m *WorkListItemPb) XXX_Size() int {
	return xxx_messageInfo_WorkListItemPb.Size(m)
}
func (m *WorkListItemPb) XXX_DiscardUnknown() {
	xxx_messageInfo_WorkListItemPb.DiscardUnknown(m)
}

var xxx_messageInfo_WorkListItemPb proto.InternalMessageInfo

func (m *WorkListItemPb) GetId() string {
	if m != nil {
		return m.Id
	}
	return ""
}

func (m *WorkListItemPb) GetTitle() string {
	if m != nil {
		return m.Title
	}
	return ""
}

func (m *WorkListItemPb) GetState() WorkListItemPb_State {
	if m != nil {
		return m.State
	}
	return WorkListItemPb_STATE_UNSPECIFIED
}

func (m *WorkListItemPb) GetCreatedAt() *timestamp.Timestamp {
	if m != nil {
		return m.CreatedAt
	}
	return nil
}

func (m *WorkListItemPb) GetUpdatedAt() *timestamp.Timestamp {
	if m != nil {
		return m.UpdatedAt
	}
	return nil
}

func init() {
	proto.RegisterType((*WorkListPb)(nil), "WorkListPb")
	proto.RegisterType((*WorkListItemPb)(nil), "WorkListItemPb")
	proto.RegisterEnum("WorkListItemPb_State", WorkListItemPb_State_name, WorkListItemPb_State_value)
}

func init() { proto.RegisterFile("worklist.proto", fileDescriptor_worklist_4171545308b7c143) }

var fileDescriptor_worklist_4171545308b7c143 = []byte{
	// 337 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0x84, 0x8f, 0x4f, 0x6b, 0xab, 0x50,
	0x14, 0xc4, 0x9f, 0x26, 0x26, 0x2f, 0x27, 0x2f, 0xc6, 0x77, 0x69, 0x40, 0xb2, 0xa9, 0x04, 0x5a,
	0x84, 0x82, 0x81, 0x74, 0xd5, 0xa5, 0xad, 0x37, 0x54, 0x68, 0x83, 0xf8, 0x87, 0x42, 0xbb, 0x10,
	0xad, 0xb7, 0x22, 0xd1, 0x5c, 0xd1, 0x13, 0xda, 0x0f, 0xd7, 0x0f, 0x57, 0xd4, 0xb8, 0x68, 0x37,
	0x5d, 0x9e, 0x33, 0xbf, 0x19, 0x66, 0x40, 0x7e, 0xe7, 0xd5, 0x3e, 0xcf, 0x6a, 0x34, 0xca, 0x8a,
	0x23, 0x5f, 0x9e, 0xa7, 0x9c, 0xa7, 0x39, 0x5b, 0xb7, 0x57, 0x7c, 0x7c, 0x5b, 0x63, 0x56, 0xb0,
	0x1a, 0xa3, 0xa2, 0xec, 0x80, 0xd5, 0x0b, 0xc0, 0x13, 0xaf, 0xf6, 0x0f, 0x59, 0x8d, 0x4e, 0x4c,
	0x2e, 0x40, 0x6a, 0x02, 0x6a, 0x55, 0xd0, 0x06, 0xfa, 0x74, 0x33, 0x37, 0x7a, 0xcd, 0x46, 0x56,
	0x38, 0xb1, 0xdb, 0xa9, 0xe4, 0x12, 0xe6, 0x07, 0xf6, 0x81, 0x61, 0x19, 0xa5, 0x2c, 0x44, 0xbe,
	0x67, 0x07, 0x55, 0xd4, 0x04, 0x7d, 0xe2, 0xce, 0x9a, 0xb7, 0x13, 0xa5, 0xcc, 0x6f, 0x9e, 0xab,
	0x4f, 0x11, 0xe4, 0xef, 0x09, 0x44, 0x06, 0x31, 0x4b, 0x54, 0xa1, 0xa5, 0xc5, 0x2c, 0x21, 0x67,
	0x20, 0x61, 0x86, 0x39, 0x3b, 0x05, 0x74, 0x07, 0xb9, 0x02, 0xa9, 0xc6, 0x08, 0x99, 0x3a, 0xd0,
	0x04, 0x5d, 0xde, 0x2c, 0x7e, 0xf4, 0x30, 0xbc, 0x46, 0x74, 0x3b, 0x86, 0xdc, 0x00, 0xbc, 0x56,
	0x2c, 0x42, 0x96, 0x84, 0x11, 0xaa, 0x43, 0x4d, 0xd0, 0xa7, 0x9b, 0xa5, 0xd1, 0x0d, 0x37, 0xfa,
	0xe1, 0x86, 0xdf, 0x0f, 0x77, 0x27, 0x27, 0xda, 0xc4, 0xc6, 0x7a, 0x2c, 0x93, 0xde, 0x2a, 0xfd,
	0x6e, 0x3d, 0xd1, 0x26, 0xae, 0x22, 0x90, 0xda, 0x16, 0x64, 0x01, 0xff, 0x3d, 0xdf, 0xf4, 0x69,
	0x18, 0xec, 0x3c, 0x87, 0xde, 0xd9, 0x5b, 0x9b, 0x5a, 0xca, 0x1f, 0x32, 0x83, 0x49, 0xb0, 0xf3,
	0x7c, 0xd3, 0xf5, 0xa9, 0xa5, 0x08, 0x64, 0x0a, 0xe3, 0xfe, 0x10, 0x09, 0xc0, 0xc8, 0x31, 0x03,
	0x8f, 0x5a, 0xca, 0xa0, 0x11, 0x5c, 0xea, 0x05, 0x8f, 0xd4, 0x52, 0x86, 0xe4, 0x1f, 0xfc, 0xdd,
	0xda, 0x3b, 0xdb, 0xbb, 0xa7, 0x96, 0x22, 0xdd, 0x8e, 0x9f, 0xa5, 0x82, 0x27, 0x2c, 0x8f, 0x47,
	0x6d, 0x95, 0xeb, 0xaf, 0x00, 0x00, 0x00, 0xff, 0xff, 0xeb, 0x8d, 0x0a, 0x45, 0xde, 0x01, 0x00,
	0x00,
}