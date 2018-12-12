// Code generated by protoc-gen-go. DO NOT EDIT.
// source: event.proto

package event

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

type EventPb_Action int32

const (
	EventPb_ACTION_UNSPECIFIED EventPb_Action = 0
	EventPb_CREATE_WORK        EventPb_Action = 1
	EventPb_UPDATE_WORK        EventPb_Action = 2
	EventPb_DELETE_WORK        EventPb_Action = 3
	EventPb_START_WORK         EventPb_Action = 4
	EventPb_PAUSE_WORK         EventPb_Action = 5
	EventPb_RESUME_WORK        EventPb_Action = 6
	EventPb_FINISH_WORK        EventPb_Action = 7
	EventPb_CANCEL_FINISH_WORK EventPb_Action = 8
)

var EventPb_Action_name = map[int32]string{
	0: "ACTION_UNSPECIFIED",
	1: "CREATE_WORK",
	2: "UPDATE_WORK",
	3: "DELETE_WORK",
	4: "START_WORK",
	5: "PAUSE_WORK",
	6: "RESUME_WORK",
	7: "FINISH_WORK",
	8: "CANCEL_FINISH_WORK",
}
var EventPb_Action_value = map[string]int32{
	"ACTION_UNSPECIFIED": 0,
	"CREATE_WORK":        1,
	"UPDATE_WORK":        2,
	"DELETE_WORK":        3,
	"START_WORK":         4,
	"PAUSE_WORK":         5,
	"RESUME_WORK":        6,
	"FINISH_WORK":        7,
	"CANCEL_FINISH_WORK": 8,
}

func (x EventPb_Action) String() string {
	return proto.EnumName(EventPb_Action_name, int32(x))
}
func (EventPb_Action) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_event_bfc29e752b622af1, []int{0, 0}
}

type EventPb struct {
	Id                   string               `protobuf:"bytes,1,opt,name=id,proto3" json:"id,omitempty"`
	PrevId               string               `protobuf:"bytes,2,opt,name=prev_id,json=prevId,proto3" json:"prev_id,omitempty"`
	WorkId               string               `protobuf:"bytes,3,opt,name=work_id,json=workId,proto3" json:"work_id,omitempty"`
	Action               EventPb_Action       `protobuf:"varint,4,opt,name=action,proto3,enum=EventPb_Action" json:"action,omitempty"`
	Title                string               `protobuf:"bytes,5,opt,name=title,proto3" json:"title,omitempty"`
	Time                 *timestamp.Timestamp `protobuf:"bytes,6,opt,name=time,proto3" json:"time,omitempty"`
	CreatedAt            *timestamp.Timestamp `protobuf:"bytes,7,opt,name=created_at,json=createdAt,proto3" json:"created_at,omitempty"`
	XXX_NoUnkeyedLiteral struct{}             `json:"-"`
	XXX_unrecognized     []byte               `json:"-"`
	XXX_sizecache        int32                `json:"-"`
}

func (m *EventPb) Reset()         { *m = EventPb{} }
func (m *EventPb) String() string { return proto.CompactTextString(m) }
func (*EventPb) ProtoMessage()    {}
func (*EventPb) Descriptor() ([]byte, []int) {
	return fileDescriptor_event_bfc29e752b622af1, []int{0}
}
func (m *EventPb) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_EventPb.Unmarshal(m, b)
}
func (m *EventPb) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_EventPb.Marshal(b, m, deterministic)
}
func (dst *EventPb) XXX_Merge(src proto.Message) {
	xxx_messageInfo_EventPb.Merge(dst, src)
}
func (m *EventPb) XXX_Size() int {
	return xxx_messageInfo_EventPb.Size(m)
}
func (m *EventPb) XXX_DiscardUnknown() {
	xxx_messageInfo_EventPb.DiscardUnknown(m)
}

var xxx_messageInfo_EventPb proto.InternalMessageInfo

func (m *EventPb) GetId() string {
	if m != nil {
		return m.Id
	}
	return ""
}

func (m *EventPb) GetPrevId() string {
	if m != nil {
		return m.PrevId
	}
	return ""
}

func (m *EventPb) GetWorkId() string {
	if m != nil {
		return m.WorkId
	}
	return ""
}

func (m *EventPb) GetAction() EventPb_Action {
	if m != nil {
		return m.Action
	}
	return EventPb_ACTION_UNSPECIFIED
}

func (m *EventPb) GetTitle() string {
	if m != nil {
		return m.Title
	}
	return ""
}

func (m *EventPb) GetTime() *timestamp.Timestamp {
	if m != nil {
		return m.Time
	}
	return nil
}

func (m *EventPb) GetCreatedAt() *timestamp.Timestamp {
	if m != nil {
		return m.CreatedAt
	}
	return nil
}

func init() {
	proto.RegisterType((*EventPb)(nil), "EventPb")
	proto.RegisterEnum("EventPb_Action", EventPb_Action_name, EventPb_Action_value)
}

func init() { proto.RegisterFile("event.proto", fileDescriptor_event_bfc29e752b622af1) }

var fileDescriptor_event_bfc29e752b622af1 = []byte{
	// 329 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0x84, 0x91, 0xc1, 0x6a, 0xea, 0x40,
	0x18, 0x85, 0x6f, 0xa2, 0x49, 0xae, 0xbf, 0xa0, 0x32, 0x5c, 0x6e, 0x83, 0x9b, 0x8a, 0x9b, 0xba,
	0x1a, 0xc1, 0xae, 0xba, 0x9c, 0xc6, 0x91, 0x0e, 0xb5, 0x31, 0x4c, 0x12, 0x0a, 0xdd, 0x84, 0x68,
	0xa6, 0x12, 0xaa, 0x46, 0xd2, 0xa9, 0x7d, 0xa2, 0x2e, 0xfb, 0x8e, 0x65, 0x66, 0x62, 0xe9, 0xae,
	0xcb, 0xf3, 0x9d, 0xff, 0x84, 0x2f, 0x0c, 0x74, 0xc5, 0x49, 0x1c, 0x24, 0x3e, 0xd6, 0x95, 0xac,
	0x86, 0x97, 0xdb, 0xaa, 0xda, 0xee, 0xc4, 0x54, 0xa7, 0xf5, 0xdb, 0xf3, 0x54, 0x96, 0x7b, 0xf1,
	0x2a, 0xf3, 0xfd, 0xd1, 0x1c, 0x8c, 0x3f, 0x5a, 0xe0, 0x51, 0x35, 0x88, 0xd6, 0xa8, 0x07, 0x76,
	0x59, 0xf8, 0xd6, 0xc8, 0x9a, 0x74, 0xb8, 0x5d, 0x16, 0xe8, 0x02, 0xbc, 0x63, 0x2d, 0x4e, 0x59,
	0x59, 0xf8, 0xb6, 0x86, 0xae, 0x8a, 0x4c, 0x17, 0xef, 0x55, 0xfd, 0xa2, 0x8a, 0x96, 0x29, 0x54,
	0x64, 0x05, 0xba, 0x02, 0x37, 0xdf, 0xc8, 0xb2, 0x3a, 0xf8, 0xed, 0x91, 0x35, 0xe9, 0xcd, 0xfa,
	0xb8, 0xf9, 0x36, 0x26, 0x1a, 0xf3, 0xa6, 0x46, 0xff, 0xc0, 0x91, 0xa5, 0xdc, 0x09, 0xdf, 0xd1,
	0x7b, 0x13, 0x10, 0x86, 0xb6, 0xf2, 0xf3, 0xdd, 0x91, 0x35, 0xe9, 0xce, 0x86, 0xd8, 0xc8, 0xe3,
	0xb3, 0x3c, 0x4e, 0xce, 0xf2, 0x5c, 0xdf, 0xa1, 0x1b, 0x80, 0x4d, 0x2d, 0x72, 0x29, 0x8a, 0x2c,
	0x97, 0xbe, 0xf7, 0xeb, 0xaa, 0xd3, 0x5c, 0x13, 0x39, 0xfe, 0xb4, 0xc0, 0x35, 0x4e, 0xe8, 0x3f,
	0x20, 0x12, 0x24, 0x6c, 0x15, 0x66, 0x69, 0x18, 0x47, 0x34, 0x60, 0x0b, 0x46, 0xe7, 0x83, 0x3f,
	0xa8, 0x0f, 0xdd, 0x80, 0x53, 0x92, 0xd0, 0xec, 0x71, 0xc5, 0xef, 0x07, 0x96, 0x02, 0x69, 0x34,
	0xff, 0x06, 0xb6, 0x02, 0x73, 0xba, 0xa4, 0x67, 0xd0, 0x42, 0x3d, 0x80, 0x38, 0x21, 0x3c, 0x31,
	0xb9, 0xad, 0x72, 0x44, 0xd2, 0xb8, 0xe9, 0x1d, 0x35, 0xe0, 0x34, 0x4e, 0x1f, 0x1a, 0xe0, 0x2a,
	0xb0, 0x60, 0x21, 0x8b, 0xef, 0x0c, 0xf0, 0x94, 0x4c, 0x40, 0xc2, 0x80, 0x2e, 0xb3, 0x9f, 0xfc,
	0xef, 0xad, 0xf7, 0xe4, 0xe8, 0x77, 0x5d, 0xbb, 0xfa, 0xbf, 0xae, 0xbf, 0x02, 0x00, 0x00, 0xff,
	0xff, 0xe2, 0x8b, 0x33, 0x10, 0xe7, 0x01, 0x00, 0x00,
}