import SwiftUI
import Supabase

struct ReviewUpdatePayload: Encodable {
    let rating: Int
    let comment: String
}

struct WriteReviewView: View {
    let order: BookingRow
    @Environment(\.dismiss) var dismiss

    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var isLoading = true
    @State private var submitted = false
    @State private var existingReviewID: Int? = nil
    @State private var errorMessage: String? = nil

    var shopID: String { order.shop_id ?? "" }
    var isEditing: Bool { existingReviewID != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: isEditing ? "star.bubble.fill" : "star.bubble")
                            .font(.system(size: 52))
                            .foregroundColor(.brandPrimary)

                        Text(isEditing ? "Edit Your Review" : "Leave a Review")
                            .font(.system(size: 28, weight: .black, design: .rounded))

                        Text("\(order.device_brand ?? "") \(order.device_model ?? "") · \(order.problem_name ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        if isEditing {
                            Label("You've already reviewed this order", systemImage: "checkmark.seal.fill")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)

                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else {
                        // Star Rating
                        VStack(spacing: 12) {
                            Text("Your Rating")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            rating = star
                                        }
                                    } label: {
                                        Image(systemName: star <= rating ? "star.fill" : "star")
                                            .font(.system(size: 36))
                                            .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.3))
                                            .scaleEffect(star <= rating ? 1.1 : 1.0)
                                    }
                                }
                            }

                            Text(ratingLabel)
                                .font(.subheadline.bold())
                                .foregroundColor(.brandPrimary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .padding(.horizontal)

                        // Comment
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Comment")
                                .font(.headline)
                                .padding(.horizontal)

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $comment)
                                    .frame(minHeight: 120)
                                    .padding(12)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 1)
                                    )

                                if comment.isEmpty {
                                    Text("Tell others about your experience...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary.opacity(0.5))
                                        .padding(.horizontal, 16)
                                        .padding(.top, 20)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal)
                        }

                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }

                        // Submit / Update Button
                        Button {
                            Task { await saveReview() }
                        } label: {
                            HStack {
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                    Text("Saving...").bold()
                                } else if submitted {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(isEditing ? "Review Updated!" : "Review Submitted!").bold()
                                } else {
                                    Image(systemName: isEditing ? "pencil.circle.fill" : "paperplane.fill")
                                    Text(isEditing ? "Update Review" : "Submit Review")
                                        .font(.headline.bold())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(submitted ? Color.green : Color.brandPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.brandPrimary.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(isSubmitting || submitted || comment.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Review" : "Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await loadExistingReview()
            }
        }
    }

    var ratingLabel: String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Excellent!"
        default: return ""
        }
    }

    // MARK: - Load existing review for this shop
    @MainActor
    private func loadExistingReview() async {
        guard !shopID.isEmpty else { isLoading = false; return }
        do {
            let rows: [ReviewRow] = try await supabase
                .from("reviews")
                .select()
                .eq("shop_id", value: shopID)
                .limit(1)
                .execute()
                .value
            if let existing = rows.first {
                existingReviewID = existing.review_id
                rating = existing.rating ?? 5
                comment = existing.comment ?? ""
            }
        } catch {
            print("❌ loadExistingReview error: \(error)")
        }
        isLoading = false
    }

    // MARK: - Create or Update review
    @MainActor
    private func saveReview() async {
        guard !shopID.isEmpty else {
            errorMessage = "Could not identify the shop."
            return
        }
        isSubmitting = true
        errorMessage = nil
        do {
            if let reviewID = existingReviewID {
                let payload = ReviewUpdatePayload(rating: rating, comment: comment)
                    try await supabase
                        .from("reviews")
                        .update(payload)
                        .eq("review_id", value: reviewID)
                        .execute()
                print("✅ Review updated: \(reviewID)")
            } else {
                // INSERT new
                try await SupabaseManager.shared.createReview(
                    shopID: shopID,
                    rating: rating,
                    comment: comment
                )
            }
            withAnimation { submitted = true }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            dismiss()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
        isSubmitting = false
    }
}
