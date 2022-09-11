//
//  OrderConfirmationNoteView.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/05/08.
//

import Foundation
import SwiftUI

struct OrderConfirmationNoteView: View {
    @Binding var note: String
    @State var willUpdateNote: String?
    
    var body: some View {
        Button {
            willUpdateNote = note
        } label: {
            if note.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "pencil.tip.crop.circle.badge.plus")
                    Text("Thêm ghi chú").italic()
                    Spacer()
                }.font(.subheadline).foregroundColor(.primary)
            } else {
                HStack {
                    VStack {
                        HStack {
                            Text("Ghi chú").bold()
                            Image(systemName: "pencil.circle.fill")
                            Spacer()
                        }.font(.caption)
                        .foregroundColor(.secondary)
                        
                        HStack {
                            Text(note)
                                .italic()
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    Spacer()
                    Button {
                        note = ""
                    } label: {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(item: $willUpdateNote) { note in
            NavigationView {
                NoteEditor(note: note) { self.note = $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .navigationTitle("Ghi chú")
                    .navigationBarTitleDisplayMode(.inline)
            }.navigationViewStyle(.stack)
        }
    }
}

struct NoteEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State var note: String
    var onFinished: (String) -> Void
    
    var body: some View {
        VStack {
            TextEditor(text: $note)
                .font(.subheadline)
                .frame(maxHeight: 320, alignment: .top)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.secondary, lineWidth: 0.5, antialiased: true)
                )
            if !note.isEmpty {
                HStack {
                    Spacer()
                    Button {
                        note = ""
                    } label: {
                        Text("Xoá nội dung").font(.subheadline).foregroundColor(.blue)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cập nhật") {
                    onFinished(note)
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Huỷ") {
                    dismiss()
                }
            }
        }
    }
}
