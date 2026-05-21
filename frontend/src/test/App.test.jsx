import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import App from "../App";

function mockFetchSuccess() {
  global.fetch = vi.fn().mockResolvedValue({
    ok: true,
    json: async () => ({
      id: 1,
      pressedAt: "2026-05-21T14:00:00Z",
      ipAddress: "203.0.113.10"
    })
  });
}

describe("App", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("calls backend and shows saved event on success", async () => {
    mockFetchSuccess();

    render(<App />);
    fireEvent.click(screen.getByRole("button", { name: "Press me" }));

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith("http://localhost:8080/api/click", {
        method: "POST"
      });
    });

    expect(await screen.findByText(/Saved event #1/)).toBeInTheDocument();
  });

  it("shows error message on failed request", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: false,
      status: 500
    });

    render(<App />);
    fireEvent.click(screen.getByRole("button", { name: "Press me" }));

    expect(await screen.findByText(/Error: Request failed with status 500/)).toBeInTheDocument();
  });
});
